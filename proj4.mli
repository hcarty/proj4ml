type t
val pj_init : string array -> t
val pj_fwd : float array -> t -> float array
val pj_inv : float array -> t -> float array
val pj_transform : t -> t -> int -> float array -> float array ->
  float array -> float array * float array * float array
