class Vec3
{
  float x, y, z;
  
  Vec3(float x=0, float y=0, float z=0)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  float magnitude()
  {
    return sqrt(x * x + y * y + z * z);
  }
  
  float sqr_magnitude()
  {
    return x * x + y * y + z * z;
  }
  
  void normalise()
  {
    float length = sqrt(x * x + y * y);
    
    if(length != 0)
    {
      x /= length;
      y /= length;
      z /= length;
    }
    else
    {
      x = y = z = 0;
    }
  }
  
  bool opEquals(const Vec3 &in other)
  {
    return x == other.x && y == other.y && z == other.z;
  }
  
  Vec3@ opDivAssign(const float &in v)
  {
    if(v != 0)
    {
      x /= v;
      y /= v;
    }
    else
    {
      x = y = 0;
    }
    
    return this;
  }
  
  Vec3@ opMulAssign(const float &in v)
  {
    x *= v;
    y *= v;
    z *= v;
    return this;
  }
  
  bool equals(const float &in x, const float &in y, const float &in z = 0)
  {
    return this.x == x && this.y == y && this.z == z;
  }
  
  void set(const float &in x, const float &in y, const float &in z = 0)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  void set(const Vec3 &in v)
  {
    x = v.x;
    y = v.y;
    z = v.z;
  }

  void print() {
    puts("Vec3: x " + x + " y " + y + " z " + z);
  }
}