(** OCaml interface for the PROJ.4 library *)

(** Projection type *)
type t

external init_plus : string -> t = "ml_pj_init_plus"
external transform : t -> t -> float array -> float array ->
  float array * float array = "ml_pj_transform"
external is_latlong : t -> bool = "ml_pj_is_latlong"
external is_geocent : t -> bool = "ml_pj_is_geocent"
external get_def : t -> string = "ml_pj_get_def"
external latlong_from_proj : t -> t = "ml_pj_latlong_from_proj"

