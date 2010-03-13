(** OCaml interface for the PROJ.4 library *)

(** Projection type *)
type t

external pj_init : string array -> t = "ml_pj_init"
external pj_fwd : float array -> t -> float array = "ml_pj_fwd"
external pj_inv : float array -> t -> float array = "ml_pj_inv"
external pj_transform : t -> t -> int -> float array -> float array ->
  float array -> float array * float array * float array =
    "ml_pj_transform_byte" "ml_pj_transform"

