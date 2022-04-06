*========================================
* Private instance
* importing json   TYPE string
* changing  object TYPE any
* changing  offset type i default 0
* exception zcx_invalid_data
*========================================
method JSON_TO_COMPONENT.
  DATA: lv_lengt TYPE i,
        lv_sname TYPE string,
        lv_value TYPE string,
        lv_numbr TYPE string.

  FIND REGEX '"([^"]*)"' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_sname.
  IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
  TRANSLATE lv_sname TO UPPER CASE.
  ADD lv_lengt TO offset.

  FIND REGEX '\{|\[|"([^"]*)"|([\d\.\w]+)' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value lv_numbr.
  IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
  CASE json+offset(1).
    WHEN '"'.
      object = lv_value.
      REPLACE ALL OCCURRENCES OF `\'` IN object WITH '"'.
    WHEN OTHERS.
      TRANSLATE lv_numbr TO UPPER CASE.
      CASE lv_numbr.
        WHEN 'NULL'.
          CLEAR object.
        WHEN 'TRUE'.
          object = abap_true.
        WHEN 'FALSE'.
          object = abap_false.
        WHEN OTHERS.
          object = lv_numbr.
      ENDCASE.
  ENDCASE.
endmethod.
