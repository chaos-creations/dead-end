/*
 * Travois used to drag mobs in low-tech settings.
 */
// TODO: Should this really be a bed subtype?
// Only really needs the grab_attack handling from beds, doesn't it?
/obj/structure/bed/travois
	name = "travois"
	anchored = FALSE
	icon_state = ICON_STATE_WORLD
	icon = 'icons/obj/structures/travois.dmi'
	buckle_pixel_shift = list("x" = 0, "y" = 0, "z" = 6)
	movable_flags = MOVABLE_FLAG_WHEELED
	user_comfort = 0
	material = /decl/material/solid/organic/wood/oak

/obj/structure/bed/travois/can_apply_padding()
	return FALSE