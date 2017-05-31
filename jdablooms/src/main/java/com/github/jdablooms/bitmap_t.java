/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.12
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package com.github.jdablooms;

public class bitmap_t {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected bitmap_t(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(bitmap_t obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        cdabloomsJNI.delete_bitmap_t(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public void setBytes(long value) {
    cdabloomsJNI.bitmap_t_bytes_set(swigCPtr, this, value);
  }

  public long getBytes() {
    return cdabloomsJNI.bitmap_t_bytes_get(swigCPtr, this);
  }

  public void setFd(int value) {
    cdabloomsJNI.bitmap_t_fd_set(swigCPtr, this, value);
  }

  public int getFd() {
    return cdabloomsJNI.bitmap_t_fd_get(swigCPtr, this);
  }

  public void setArray(String value) {
    cdabloomsJNI.bitmap_t_array_set(swigCPtr, this, value);
  }

  public String getArray() {
    return cdabloomsJNI.bitmap_t_array_get(swigCPtr, this);
  }

  public bitmap_t() {
    this(cdabloomsJNI.new_bitmap_t(), true);
  }

}
