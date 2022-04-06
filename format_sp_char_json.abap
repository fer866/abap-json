*========================================
* Private static
* changing json TYPE string
*========================================
method FORMAT_SP_CHAR_JSON.
  REPLACE ALL OCCURRENCES OF '\\' IN json WITH '\'.
  REPLACE ALL OCCURRENCES OF '\"' IN json WITH `\'`.
endmethod.
