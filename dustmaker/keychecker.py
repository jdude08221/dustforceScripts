import argparse
import gspread
from google.oauth2.service_account import Credentials
from dustmaker.dfreader import DFReader
from dustmaker.entity import Apple
from enum import IntEnum
import os
import re
import time
import gc
import gspread.utils  # for rowcol_to_a1
from gspread_formatting import format_cell_range, CellFormat, TextFormat, Color
from tqdm import tqdm  # for progress bars
from concurrent.futures import ProcessPoolExecutor, as_completed
from multiprocessing import freeze_support

# -------------------------------------
# Command-line Argument Parsing
# -------------------------------------
parser = argparse.ArgumentParser(description="Process level files and update Google Sheets.")
parser.add_argument("-d", "--debug", action="store_true", help="Enable debug mode")
args = parser.parse_args()
DEBUG_MODE = args.debug

def debug_print(message):
    if DEBUG_MODE:
        print(message)

# -------------------------------------
# Configuration & Constants
# -------------------------------------
CATEGORY_ROW_1 = ["ForestMap", "Mountain", "Difficult"]
CATEGORY_ROW_2 = ["Rainlands", "Ocean"]

# This dictionary will be populated with file data based on filename prefix.
category_data = {cat: [] for cat in CATEGORY_ROW_1 + CATEGORY_ROW_2}

TABLE_WIDTH = 4
COLUMN_SPACING = 1

# Background colors for categories
CATEGORY_COLORS = {
    "ForestMap": Color(0.8, 1.0, 0.8),  # Light Green
    "Rainlands": Color(1.0, 1.0, 0.8),  # Pale Yellow
    "Mountain": Color(1.0, 0.9, 0.7),   # Beige / Light Brown
    "Ocean": Color(0.8, 0.9, 1.0),        # Light Blue
    "Difficult": Color(1.0, 0.8, 0.8)     # Soft Red
}

HEADER_COLOR = Color(0.85, 0.85, 0.85)  # Light Gray
# Updated alternate row color for more contrast.
ALT_ROW_COLOR = Color(0.9, 0.9, 0.9)  # A bit darker for better contrast

# -----------------------------
# Restored Missing Variables
# (These will be recomputed after category_data is populated.)
# -----------------------------
START_ROW_ROW1 = 1
max_data_rows_top = max(len(category_data[cat]) for cat in CATEGORY_ROW_1) if CATEGORY_ROW_1 else 0
START_ROW_ROW2 = START_ROW_ROW1 + 1 + max_data_rows_top + 2
START_COL = 1

# -------------------------------------
# Helper Types and Functions
# -------------------------------------
class KeyTypes(IntEnum):
    NONE = 0
    WOOD = 4
    SILVER = 1
    GOLD = 2
    RED = 3

def extract_num(s):
    """Extracts numeric portion from filename for sorting."""
    m = re.search(r'\d+', s)
    return int(m.group()) if m else 0

def clear_sheet_formatting_and_merges(worksheet):
    try:
        sheet_id = worksheet._properties["sheetId"]
        requests = [
            {"repeatCell": {"range": {"sheetId": sheet_id},
                            "cell": {"userEnteredFormat": {}},
                            "fields": "userEnteredFormat"}},
            {"unmergeCells": {"range": {"sheetId": sheet_id,
                                        "startRowIndex": 0,
                                        "endRowIndex": worksheet.row_count,
                                        "startColumnIndex": 0,
                                        "endColumnIndex": worksheet.col_count}}
            }
        ]
        worksheet.spreadsheet.batch_update({"requests": requests})
    except Exception as e:
        debug_print(f"⚠️ DEBUG: Error clearing formatting: {e}")

def apply_outer_borders(worksheet, start_row, start_col, num_rows, num_cols, draw_left=True, draw_right=True):
    try:
        sheet_id = worksheet._properties["sheetId"]
        req = {
            "updateBorders": {
                "range": {
                    "sheetId": sheet_id,
                    "startRowIndex": start_row - 1,
                    "endRowIndex": start_row - 1 + num_rows,
                    "startColumnIndex": start_col - 1,
                    "endColumnIndex": start_col - 1 + num_cols,
                },
                "top": {"style": "SOLID_THICK"},
                "bottom": {"style": "SOLID_THICK"},
                "left": {"style": "SOLID_THICK"} if draw_left else {"style": "NONE"},
                "right": {"style": "SOLID_THICK"} if draw_right else {"style": "NONE"},
                "innerHorizontal": {"style": "NONE"},
                "innerVertical": {"style": "SOLID"}  # thin vertical inner borders
            }
        }
        worksheet.spreadsheet.batch_update({"requests": [req]})
    except Exception as e:
        debug_print(f"⚠️ DEBUG: Error applying borders: {e}")

def format_title_cell(worksheet, start_row, start_col, num_cols):
    try:
        worksheet.merge_cells(start_row, start_col, start_row, start_col + num_cols - 1)
        title_format = CellFormat(textFormat=TextFormat(bold=True), horizontalAlignment='CENTER')
        merged_range = f"{gspread.utils.rowcol_to_a1(start_row, start_col)}:" \
                       f"{gspread.utils.rowcol_to_a1(start_row, start_col + num_cols - 1)}"
        format_cell_range(worksheet, merged_range, title_format)
    except Exception as e:
        debug_print(f"⚠️ DEBUG: Error merging title cells: {e}")

def process_file(filepath):
    """Reads a level file and extracts relevant data."""
    try:
        with open(filepath, "rb") as f:
            level = DFReader(f).read_level()
        filename = os.path.basename(filepath)
        level_name = level.variables["level_name"].value.decode("utf-8")
        key_type_str = (KeyTypes(level.variables["key_get_type"].value).name
                        if level.variables["key_get_type"].value in KeyTypes._value2member_map_
                        else "UNKNOWN")
        apples = sum(1 for _, _, entity in level.entities.values() if isinstance(entity, Apple))
        return filename, level_name, key_type_str, apples
    except Exception as e:
        debug_print(f"⚠️ DEBUG: Error processing file {filepath}: {e}")
        return None

def apply_formatting(worksheet, start_row, start_col, num_data_rows, num_cols, category_name):
    """
    Applies color formatting:
      - Title row gets the category color.
      - Header row gets a light gray background.
      - Data rows are alternated with a light gray background.
    Note: num_data_rows is the count of data rows (excluding title and header).
    """
    try:
        # Title row (row = start_row)
        title_range = f"{gspread.utils.rowcol_to_a1(start_row, start_col)}:" \
                      f"{gspread.utils.rowcol_to_a1(start_row, start_col+num_cols-1)}"
        title_format = CellFormat(
            backgroundColor=CATEGORY_COLORS.get(category_name, Color(1, 1, 1)),
            textFormat=TextFormat(bold=True)
        )
        format_cell_range(worksheet, title_range, title_format)
        
        # Header row (row = start_row+1)
        header_range = f"{gspread.utils.rowcol_to_a1(start_row+1, start_col)}:" \
                       f"{gspread.utils.rowcol_to_a1(start_row+1, start_col+num_cols-1)}"
        header_format = CellFormat(
            backgroundColor=HEADER_COLOR,
            textFormat=TextFormat(bold=True)
        )
        format_cell_range(worksheet, header_range, header_format)
        
        # Data rows: apply alternating background color.
        for i in range(num_data_rows):
            current_row = start_row + 2 + i
            # For even-indexed data rows, apply ALT_ROW_COLOR.
            if i % 2 == 0:
                data_range = f"{gspread.utils.rowcol_to_a1(current_row, start_col)}:" \
                             f"{gspread.utils.rowcol_to_a1(current_row, start_col+num_cols-1)}"
                row_format = CellFormat(backgroundColor=ALT_ROW_COLOR)
                format_cell_range(worksheet, data_range, row_format)
                
    except Exception as e:
        debug_print(f"⚠️ DEBUG: Error applying formatting: {e}")

# -------------------------------------
# Main Execution (Parallel File Processing + Serial Google Sheets Updates)
# -------------------------------------
if __name__ == '__main__':
    freeze_support()

    # Process files using multiprocessing.
    files = [f for f in os.listdir('.') if os.path.isfile(f)]
    debug_print(f"Found {len(files)} files.")
    
    results = []
    with ProcessPoolExecutor(max_workers=os.cpu_count()) as executor:
        future_to_file = {executor.submit(process_file, file): file for file in files}
        for future in tqdm(as_completed(future_to_file), total=len(future_to_file),
                           desc="Processing Files", unit="file"):
            result = future.result()
            if result:
                results.append(result)
    
    # Assign files to categories.
    for filename, level_name, key_type_str, apples in results:
        for category in CATEGORY_ROW_1 + CATEGORY_ROW_2:
            if filename.startswith(category):
                category_data[category].append((filename, level_name, key_type_str, apples))
                break
    
    # Initialize Google Sheets.
    creds = Credentials.from_service_account_file(
        "D:\\test\\key_checker\\nexus-461114-065a37b2b43e.json",
        scopes=["https://www.googleapis.com/auth/spreadsheets", "https://www.googleapis.com/auth/drive"]
    )
    client = gspread.authorize(creds)
    sheet = client.open("Nexus_Map_Completion")
    try:
        worksheet = sheet.worksheet("Auto_Check")
    except gspread.exceptions.WorksheetNotFound:
        worksheet = sheet.add_worksheet(title="Auto_Check", rows="100", cols="30")
    
    worksheet.clear()
    clear_sheet_formatting_and_merges(worksheet)
    
    # Now compute the sheet layout variables AFTER category_data is populated.
    START_ROW_ROW1 = 1
    max_data_rows_top = max(len(category_data[cat]) for cat in CATEGORY_ROW_1) if CATEGORY_ROW_1 else 0
    START_ROW_ROW2 = START_ROW_ROW1 + 1 + max_data_rows_top + 2
    START_COL = 1
    
    # Update Google Sheets with a progress bar.
    progress_bar_sheets = tqdm(CATEGORY_ROW_1 + CATEGORY_ROW_2, desc="Updating Google Sheets",
                               unit="category", dynamic_ncols=True)
    for category in progress_bar_sheets:
        if category in CATEGORY_ROW_1:
            current_row = START_ROW_ROW1
            col_index = CATEGORY_ROW_1.index(category)
        else:
            current_row = START_ROW_ROW2
            col_index = CATEGORY_ROW_2.index(category)
        col_offset = START_COL + col_index * (TABLE_WIDTH + COLUMN_SPACING)
        
        progress_bar_sheets.set_postfix(category=category)
        
        # Write the category title cell and format it.
        worksheet.update_cell(current_row, col_offset, f"{category} Levels")
        format_title_cell(worksheet, current_row, col_offset, TABLE_WIDTH)
        
        # Batch update the header row.
        headers = ["Filename", "Level Name", "Key Type", "Apples"]
        header_range = f"{gspread.utils.rowcol_to_a1(current_row+1, col_offset)}:" \
                       f"{gspread.utils.rowcol_to_a1(current_row+1, col_offset+len(headers)-1)}"
        worksheet.update(values=[headers], range_name=header_range)
        
        # Sort and prepare data rows.
        data = category_data[category]
        data.sort(key=lambda x: extract_num(x[0]))
        rows_to_add = [list(row[:4]) for row in data]
        debug_print(f"Sending data for {category}: {rows_to_add}")
        
        if rows_to_add:
            start_a1 = gspread.utils.rowcol_to_a1(current_row + 2, col_offset)
            end_a1 = gspread.utils.rowcol_to_a1(current_row + 1 + len(rows_to_add), 
                                                col_offset + TABLE_WIDTH - 1)
            worksheet.update(values=rows_to_add, range_name=f"{start_a1}:{end_a1}")
        
        # Apply outer borders.
        apply_outer_borders(worksheet, current_row, col_offset,
                            len(rows_to_add) + 2, TABLE_WIDTH)
        
        # Apply color formatting.
        num_data_rows = len(rows_to_add)
        apply_formatting(worksheet, current_row, col_offset, num_data_rows,
                         TABLE_WIDTH, category)
        
        # Delay to mitigate write quota issues.
        time.sleep(1)
    
    debug_print("Script completed successfully!")