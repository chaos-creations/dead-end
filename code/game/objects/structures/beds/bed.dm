// Beds... get your mind out of the gutter, they're for sleeping!
// TODO by end of Q2 2025: Repath /obj/structure/bed/chair to just /obj/structure/chair.
// Remaining steps:
// - Move padding interactions and padding_color var onto an extension
/obj/structure/bed
	name = "bed"
	desc = "A raised, padded platform for sleeping on. This one has straps for ensuring restful snoozing in microgravity."
	icon = 'icons/obj/structures/furniture/bed.dmi'
	icon_state = ICON_STATE_WORLD
	anchored = TRUE
	can_buckle = TRUE
	buckle_dir = SOUTH
	buckle_lying = TRUE
	buckle_sound = 'sound/effects/buckle.ogg'
	material = DEFAULT_FURNITURE_MATERIAL
	material_alteration = MAT_FLAG_ALTERATION_ALL
	tool_interaction_flags = TOOL_INTERACTION_DECONSTRUCT
	parts_amount = 2
	parts_type = /obj/item/stack/material/rods
	user_comfort = 1
	obj_flags = OBJ_FLAG_SUPPORT_MOB
	var/padding_color

/obj/structure/bed/user_can_mousedrop_onto(mob/user, atom/being_dropped, incapacitation_flags, params)
	if(user == being_dropped)
		return user.Adjacent(src) && !user.incapacitated(INCAPACITATION_STUNNED|INCAPACITATION_KNOCKOUT)
	return ..()

/obj/structure/bed/get_base_value()
	. = round(..() * 2.5) // Utility structures should be worth more than their matter (wheelchairs, rollers, etc).

/obj/structure/bed/get_surgery_surface_quality(mob/living/victim, mob/living/user)
	return OPERATE_PASSABLE

/obj/structure/bed/get_surgery_success_modifier(delicate)
	return delicate ? -5 : 0

/obj/structure/bed/update_material_name(override_name)
	var/base_name = override_name || initial(name)
	var/new_name = base_name
	if(reinf_material)
		new_name = "[reinf_material.adjective_name] [base_name]"
	else if(material)
		new_name = "[material.adjective_name] [base_name]"
	if(name_prefix)
		new_name = "[name_prefix] [new_name]"
	SetName(new_name)

/obj/structure/bed/update_material_desc()
	if(reinf_material)
		desc = "[initial(desc)] It's made of [material.use_name] and covered with [reinf_material.use_name]."
	else
		desc = "[initial(desc)] It's made of [material.use_name]."

/obj/structure/bed/proc/get_base_icon()
	return ICON_STATE_WORLD

/obj/structure/bed/on_update_icon()
	..()
	icon_state = get_base_icon()
	if(istype(reinf_material))
		if(material_alteration & MAT_FLAG_ALTERATION_COLOR)
			add_overlay(overlay_image(icon, "[icon_state]_padding", padding_color || reinf_material.color, RESET_COLOR))
		else
			add_overlay(overlay_image(icon, "[icon_state]_padding"))

/obj/structure/bed/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASS_FLAG_TABLE))
		return 1
	return ..()

/obj/structure/bed/explosion_act(severity)
	. = ..()
	if(. && !QDELETED(src) && (severity == 1 || (severity == 2 && prob(50)) || (severity == 3 && prob(5))))
		physically_destroyed()

/obj/structure/bed/proc/can_apply_padding()
	return TRUE

/obj/structure/bed/attackby(obj/item/used_item, mob/user)

	if((. = ..()))
		return

	if(istype(used_item, /obj/item/stack) && can_apply_padding())

		if(reinf_material)
			to_chat(user, SPAN_WARNING("\The [src] is already padded."))
			return TRUE

		var/obj/item/stack/cloth = used_item
		if(cloth.get_amount() < 1)
			to_chat(user, SPAN_WARNING("You need at least one unit of material to pad \the [src]."))
			return TRUE

		var/padding_type
		var/new_padding_color
		if(istype(used_item, /obj/item/stack/tile) || istype(used_item, /obj/item/stack/material/bolt))
			padding_type = used_item.material?.type
			new_padding_color = used_item.paint_color

		if(padding_type)
			var/decl/material/padding_mat = GET_DECL(padding_type)
			if(!istype(padding_mat) || !(padding_mat.flags & MAT_FLAG_PADDING))
				padding_type = null

		if(!padding_type)
			to_chat(user, SPAN_WARNING("You cannot pad \the [src] with that."))
			return TRUE

		cloth.use(1)
		if(!isturf(src.loc))
			src.forceMove(get_turf(src))
		playsound(src.loc, 'sound/effects/rustle5.ogg', 50, 1)
		to_chat(user, SPAN_NOTICE("You add padding to \the [src]."))
		add_padding(padding_type, new_padding_color)
		return TRUE

	if(IS_WIRECUTTER(used_item))
		if(!reinf_material)
			to_chat(user, SPAN_WARNING("\The [src] has no padding to remove."))
		else
			to_chat(user, SPAN_NOTICE("You remove the padding from \the [src]."))
			playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
			remove_padding()
		return TRUE

/obj/structure/bed/proc/add_padding(var/padding_type, var/new_padding_color)
	reinf_material = GET_DECL(padding_type)
	padding_color = new_padding_color
	update_icon()

/obj/structure/bed/proc/remove_padding()
	if(reinf_material)
		var/list/res = reinf_material.create_object(get_turf(src))
		if(padding_color)
			for(var/obj/item/thing in res)
				thing.set_color(padding_color)
	reinf_material = null
	padding_color = null
	update_icon()

/obj/structure/bed/psych
	name = "psychiatrist's couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon = 'icons/obj/structures/furniture/bed_psych.dmi'
	material = /decl/material/solid/organic/wood/walnut

/obj/structure/bed/psych/leather
	reinf_material = /decl/material/solid/organic/leather

/obj/structure/bed/padded
	material = /decl/material/solid/metal/aluminium
	reinf_material = /decl/material/solid/organic/cloth
