/*
 * An OCaml wrapper for the PROJ.4 C library.
 * by Hezekiah M. Carty
 *
 */

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
#include <projects.h>

/* For debugging - we want to have access to printf, stderr and such */
#include <stdio.h>
#include <string.h>

// Allow for ridiculously long exception strings.
#define MAX_EXCEPTION_MESSAGE_LENGTH 10000

#define UV projUV

#define PJ_val(val) (* ((PJ **) Data_custom_val(val)))

// OCaml handler to free a projection when it is GC'd
void finalize_projection(value ml_projection) {
    PJ *projection;
    projection = PJ_val(ml_projection);
    pj_free(projection);
    return;
}

// Definition for custom OCaml handler functions
static struct custom_operations projection_custom_ops = {
    identifier: "projection handling",
    finalize: finalize_projection,
    compare: custom_compare_default,
    hash: custom_hash_default,
    serialize: custom_serialize_default,
    deserialize: custom_deserialize_default
};

value Val_PJ(PJ *p) {
    PJ **store;
    value ret;
    ret = caml_alloc_custom(&projection_custom_ops, sizeof(p), 0, 1);
    store = Data_custom_val(ret);
    *store = p;
    return ret;
}

// Wrapper for pj_init
value ml_pj_init(value argv) {
    CAMLparam1(argv);
    CAMLlocal1(ml_projection);

    int i;
    PJ *projection;

    // Count the number of elements in the passed array
    int argv_length;
    argv_length = Wosize_val(argv);

    // Make a copy of the command line argument strings
    const char* argv_copy[argv_length];
    for (i = 0; i < argv_length; i++) {
        argv_copy[i] = String_val(Field(argv, i));
    }

    projection = pj_init(argv_length, (char **)argv_copy);

    if (!projection) {
        char exception_message[MAX_EXCEPTION_MESSAGE_LENGTH];
        sprintf(exception_message, "Projection initialization failed");
        caml_invalid_argument(exception_message);
    }

    CAMLreturn(Val_PJ(projection));
}

// Forward projection
value ml_pj_fwd(value ml_input, value projection) {
    CAMLparam2(ml_input, projection);
    CAMLlocal1(ml_result);

    UV input;
    UV result;

    input.u = Double_field(ml_input, 0);
    input.v = Double_field(ml_input, 1);

    result = pj_fwd(input, PJ_val(projection));

    ml_result = caml_alloc(2 * Double_wosize, Double_array_tag);
    Store_double_field(ml_result, 0, result.u);
    Store_double_field(ml_result, 1, result.v);

    CAMLreturn(ml_result);
}

// Inverse projection
value ml_pj_inv(value ml_input, value projection) {
    CAMLparam2(ml_input, projection);
    CAMLlocal1(ml_result);

    UV input;
    UV result;

    input.u = Double_field(ml_input, 0);
    input.v = Double_field(ml_input, 1);

    result = pj_inv(input, PJ_val(projection));

    ml_result = caml_alloc(2 * Double_wosize, Double_array_tag);
    Store_double_field(ml_result, 0, result.u);
    Store_double_field(ml_result, 1, result.v);

    CAMLreturn(ml_result);
}

// Convert coordinates from one coordinate projection to another
value ml_pj_transform(value src, value dst, value offset,
                      value x, value y, value z) {
    CAMLparam5(src, dst, offset, x, y);
    CAMLxparam1(z);

    CAMLlocal4(xt, yt, zt, packed_coords);

    int result;
    int length;
    int i;

    length = Wosize_val(x) / Double_wosize;
    if ((length != Wosize_val(y) / Double_wosize) ||
        (length != Wosize_val(z) / Double_wosize)) {
        char exception_message[MAX_EXCEPTION_MESSAGE_LENGTH];
        sprintf(exception_message, "x, y, z must all be the same length");
        caml_invalid_argument(exception_message);
    }

    xt = caml_alloc(length * Double_wosize, Double_array_tag);
    yt = caml_alloc(length * Double_wosize, Double_array_tag);
    zt = caml_alloc(length * Double_wosize, Double_array_tag);
    for (i = 0; i < length; i++) {
        Store_double_field(xt, i, Double_field(x, i));
        Store_double_field(yt, i, Double_field(y, i));
        Store_double_field(zt, i, Double_field(z, i));
    }

    pj_transform(PJ_val(src), PJ_val(dst), length, Int_val(offset),
                 (double *)xt, (double *)yt, (double *)zt);

    packed_coords = caml_alloc(3, 0);
    Store_field(packed_coords, 0, xt);
    Store_field(packed_coords, 1, yt);
    Store_field(packed_coords, 2, zt);

    CAMLreturn(packed_coords);
}

value ml_pj_transform_byte(value *argv, int argn) {
    return ml_pj_transform(argv[0], argv[1], argv[2], argv[3], argv[4],
                           argv[5]);
}
