(** OCaml interface for the PROJ.4 library *)

(** Projection type *)
type t

type trans_t = {
  xt : float;
  yt : float;
}

external init_plus : string -> t = "ml_pj_init_plus"
external transform : t -> t -> float array -> float array ->
  float array * float array = "ml_pj_transform"
external transform_one : t -> t -> float -> float -> trans_t
  = "ml_pj_transform_one"
external transform_one_tuple : t -> t -> float -> float -> float * float
  = "ml_pj_transform_one_tuple"
external is_latlong : t -> bool = "ml_pj_is_latlong"
external is_geocent : t -> bool = "ml_pj_is_geocent"
external get_def : t -> string = "ml_pj_get_def"
external latlong_from_proj : t -> t = "ml_pj_latlong_from_proj"

