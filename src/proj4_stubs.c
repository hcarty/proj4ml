/*
 * An OCaml wrapper for the PROJ.4 C library.
 * by Hezekiah M. Carty
 *
 */

/* Required on versions of proj.
 */
#define ACCEPT_USE_OF_DEPRECATED_PROJ_API_H

/* The "usual" OCaml includes */
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/misc.h>
#include <caml/mlvalues.h>
#include <caml/bigarray.h>
#include <caml/custom.h>

/* PROJ.4 API include */
#include <proj_api.h>

/* For debugging - we want to have access to printf, stderr and such */
#include <stdio.h>
#include <string.h>

// Allow for ridiculously long exception strings.
#define MAX_EXCEPTION_MESSAGE_LENGTH 10000

#define PJ_val(val) (* ((projPJ **) Data_custom_val(val)))

// OCaml handler to free a projection when it is GC'd
void finalize_projection(value ml_projection) {
    projPJ *projection;
    projection = PJ_val(ml_projection);
    pj_free(projection);
    return;
}

// Definition for custom OCaml handler functions
static struct custom_operations projection_custom_ops = {
    "projection handling",
    finalize_projection,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
    NULL,			/* compare_ext */
};

value Val_PJ(projPJ *p) {
    projPJ **store;
    value ret;
    ret = caml_alloc_custom(&projection_custom_ops, sizeof(p), 0, 1);
    store = Data_custom_val(ret);
    *store = p;
    return ret;
}

// Wrapper for pj_init_plus
value ml_pj_init_plus( value args ) {
    CAMLparam1( args );

    projPJ projection;

    // Create the projection
    projection = pj_init_plus( String_val(args) );

    // Raise an exception if something went wrong
    if ( !projection ) {
        char exception_message[MAX_EXCEPTION_MESSAGE_LENGTH];
        sprintf(exception_message, "Projection initialization failed");
        caml_invalid_argument(exception_message);
    }

    CAMLreturn( Val_PJ( projection ) );
}


// Convert coordinates from one coordinate projection to another
value ml_pj_transform( value src, value dst, value x, value y ) {
    CAMLparam4( src, dst, x, y );

    CAMLlocal3( xt, yt, packed_coords );

    int result;
    int length;
    int i;

    length = Wosize_val(x) / Double_wosize;
    if ( length != Wosize_val(y) / Double_wosize ) {
        char exception_message[MAX_EXCEPTION_MESSAGE_LENGTH];
        sprintf(exception_message, "x, y must be the same length");
        caml_invalid_argument(exception_message);
    }

    xt = caml_alloc(length * Double_wosize, Double_array_tag);
    yt = caml_alloc(length * Double_wosize, Double_array_tag);
    for (i = 0; i < length; i++) {
        Store_double_field(xt, i, Double_field(x, i));
        Store_double_field(yt, i, Double_field(y, i));
    }

    result = pj_transform( PJ_val(src), PJ_val(dst), length, 1,
                           (double *)xt, (double *)yt, NULL );

    if ( result != 0 ) {
        caml_raise_with_arg(*caml_named_value("Proj4_ERR"), Val_int(result)); 
    }

    packed_coords = caml_alloc(2, 0);
    Store_field(packed_coords, 0, xt);
    Store_field(packed_coords, 1, yt);

    CAMLreturn(packed_coords);
}

// Convert single coordinate pair from one coordinate projection to another
value ml_pj_transform_one( value src, value dst, value x, value y ) {
    CAMLparam4( src, dst, x, y );

    CAMLlocal1( packed_coords );

    int result;
    double xt, yt;

    xt = Double_val(x);
    yt = Double_val(y);

    result = pj_transform( PJ_val(src), PJ_val(dst), 1, 1, &xt, &yt, NULL );

    if ( result != 0 ) {
        caml_raise_with_arg(*caml_named_value("Proj4_ERR"), Val_int(result));  
    }

    packed_coords = caml_alloc(2 * Double_wosize, Double_array_tag);
    Store_double_field(packed_coords, 0, xt);
    Store_double_field(packed_coords, 1, yt);

    CAMLreturn(packed_coords);
}

// Convert single coordinate pair from one coordinate projection to another
value ml_pj_transform_one_tuple( value src, value dst, value x, value y ) {
    CAMLparam4( src, dst, x, y );

    CAMLlocal1( packed_coords );

    int result;
    double xt, yt;

    xt = Double_val(x);
    yt = Double_val(y);

    result = pj_transform( PJ_val(src), PJ_val(dst), 1, 1, &xt, &yt, NULL );

    if ( result != 0 ) {
        caml_raise_with_arg(*caml_named_value("Proj4_ERR"), Val_int(result));         
    }

    packed_coords = caml_alloc(2, 0);
    Store_field(packed_coords, 0, caml_copy_double(xt));
    Store_field(packed_coords, 1, caml_copy_double(yt));

    CAMLreturn(packed_coords);
}

// Advanced functions from the PROJ.4 API

value ml_pj_is_latlong( value proj ) {
    CAMLparam1( proj );
    int i;
    i = pj_is_latlong( PJ_val(proj) );
    CAMLreturn( Val_bool( i ) );
}

value ml_pj_is_geocent( value proj ) {
    CAMLparam1( proj );
    int i;
    i = pj_is_geocent( PJ_val(proj) );
    CAMLreturn( Val_bool( i ) );
}

value ml_pj_get_def( value proj ) {
    CAMLparam1( proj );
    CAMLreturn( caml_copy_string ( pj_get_def( PJ_val(proj), 0 ) ) );
}

value ml_pj_latlong_from_proj( value proj ) {
    CAMLparam1( proj );
    CAMLreturn( Val_PJ( pj_latlong_from_proj( PJ_val(proj) ) ) );
}

