//YES, chairs are a type of bed. Hopefully this will be fixed by the end of Q2 2025.
/obj/structure/bed/chair
	name = "chair"
	desc = "You sit in this, either by will or force."
	icon = 'icons/obj/structures/furniture/chair.dmi'
	icon_state = "world_preview"
	color = "#666666"
	buckle_dir = 0
	buckle_lying = 0 //force people to sit up in chairs when buckled
	obj_flags = OBJ_FLAG_ROTATABLE | OBJ_FLAG_SUPPORT_MOB
	user_comfort = 0.5

	var/propelled = 0 // Check for fire-extinguisher-driven chairs
	var/has_special_overlay = FALSE

/obj/structure/bed/chair/do_simple_ranged_interaction(var/mob/user)
	if(!buckled_mob && user)
		rotate(user)
	return TRUE

/obj/structure/bed/chair/post_buckle_mob()
	update_icon()
	return ..()

/// Returns an alternate icon based on our material.
/// Mostly used by benches.
/// TODO: Refactor to eliminate?
/obj/structure/bed/chair/proc/get_material_icon()
	return icon

/obj/structure/bed/chair/update_materials()
	. = ..()
	var/icon/material_icon = get_material_icon()
	if(material_icon)
		icon = material_icon

/obj/structure/bed/chair/on_update_icon()
	..() // handles setting icon_state to get_base_icon(), and adds padding
	var/base_color = get_color()
	var/datum/extension/padding/padding_extension = get_extension(src, __IMPLIED_TYPE__)
	var/use_padding_color = padding_extension?.get_padding_color(material_alteration & MAT_FLAG_ALTERATION_COLOR)
	var/use_layer = buckled_mob ? ABOVE_HUMAN_LAYER : FLOAT_LAYER

	var/image/I = overlay_image(icon, "[icon_state]_over", base_color, RESET_COLOR)
	I.layer = use_layer
	add_overlay(I)
	I = overlay_image(icon, "[icon_state]_armrest", base_color, RESET_COLOR)
	I.layer = use_layer
	add_overlay(I)
	if(padding_extension?.get_padding_material())
		I = overlay_image(icon, "[icon_state]_padding_over", use_padding_color, RESET_COLOR)
		I.layer = use_layer
		add_overlay(I)
		I = overlay_image(icon, "[icon_state]_padding_armrest", use_padding_color, RESET_COLOR)
		I.layer = use_layer
		add_overlay(I)
	if(has_special_overlay)
		I = overlay_image(icon, "[icon_state]_special", base_color, RESET_COLOR)
		I.layer = use_layer
		add_overlay(I)

/obj/structure/bed/chair/rotate(mob/user)
	if(!CanPhysicallyInteract(user))
		to_chat(user, SPAN_NOTICE("You can't interact with \the [src] right now!"))
		return

	set_dir(turn(dir, 90))
	update_icon()

/obj/structure/bed/chair/padded
	initial_padding_material = /decl/material/solid/organic/cloth
/obj/structure/bed/chair/padded/red
	initial_padding_color = "#9d2300"
/obj/structure/bed/chair/padded/brown
	initial_padding_material = /decl/material/solid/organic/leather
/obj/structure/bed/chair/padded/teal
	initial_padding_color = "#00e1ff"
/obj/structure/bed/chair/padded/black
	initial_padding_color = "#505050"
/obj/structure/bed/chair/padded/green
	initial_padding_color = "#b7f27d"
/obj/structure/bed/chair/padded/purple
	initial_padding_color = "#9933ff"
/obj/structure/bed/chair/padded/blue
	initial_padding_color = "#46698c"
/obj/structure/bed/chair/padded/beige
	initial_padding_color = "#ceb689"
/obj/structure/bed/chair/padded/lime
	initial_padding_color = "#62e36c"
/obj/structure/bed/chair/padded/yellow
	initial_padding_color = "#ffbf00"

// Leaving this in for the sake of compilation.
/obj/structure/bed/chair/comfy
	name = "comfy chair"
	desc = "It's a chair. It looks comfy."
	icon = 'icons/obj/structures/furniture/chair_comfy.dmi'
	initial_padding_material = /decl/material/solid/organic/cloth

/obj/structure/bed/chair/comfy/unpadded
	initial_padding_material = null
/obj/structure/bed/chair/comfy/brown
	initial_padding_material = /decl/material/solid/organic/leather
/obj/structure/bed/chair/comfy/red
	initial_padding_color = "#9d2300"
/obj/structure/bed/chair/comfy/teal
	initial_padding_color = "#00e1ff"
/obj/structure/bed/chair/comfy/black
	initial_padding_color = "#505050"
/obj/structure/bed/chair/comfy/green
	initial_padding_color = "#b7f27d"
/obj/structure/bed/chair/comfy/purple
	initial_padding_color = "#9933ff"
/obj/structure/bed/chair/comfy/blue
	initial_padding_color = "#46698c"
/obj/structure/bed/chair/comfy/beige
	initial_padding_color = "#ceb689"
/obj/structure/bed/chair/comfy/lime
	initial_padding_color = "#62e36c"
/obj/structure/bed/chair/comfy/yellow
	initial_padding_color = "#ffbf00"

/obj/structure/bed/chair/comfy/captain
	name = "captain chair"
	desc = "It's a chair. Only for the highest ranked asses."
	icon = 'icons/obj/structures/furniture/chair_captain.dmi'
	buckle_movable = 1
	material = /decl/material/solid/metal/steel
	initial_padding_material = /decl/material/solid/organic/cloth
	initial_padding_color = "#46698c"
	has_special_overlay = TRUE

/obj/structure/bed/chair/armchair
	name = "armchair"
	desc = "It's an armchair. It looks comfy."
	icon = 'icons/obj/structures/furniture/armchair.dmi'
	initial_padding_material = /decl/material/solid/organic/cloth

/obj/structure/bed/chair/armchair/unpadded
	initial_padding_material = null
/obj/structure/bed/chair/armchair/brown
	initial_padding_material = /decl/material/solid/organic/leather
/obj/structure/bed/chair/armchair/red
	initial_padding_color = "#9d2300"
/obj/structure/bed/chair/armchair/teal
	initial_padding_color = "#00e1ff"
/obj/structure/bed/chair/armchair/black
	initial_padding_color = "#505050"
/obj/structure/bed/chair/armchair/green
	initial_padding_color = "#b7f27d"
/obj/structure/bed/chair/armchair/purple
	initial_padding_color = "#9933ff"
/obj/structure/bed/chair/armchair/blue
	initial_padding_color = "#46698c"
/obj/structure/bed/chair/armchair/beige
	initial_padding_color = "#ceb689"
/obj/structure/bed/chair/armchair/lime
	initial_padding_color = "#62e36c"
/obj/structure/bed/chair/armchair/yellow
	initial_padding_color = "#ffbf00"

/obj/structure/bed/chair/office
	name = "office chair"
	icon = 'icons/obj/structures/furniture/chair_office.dmi'
	anchored = FALSE
	buckle_movable = 1
	movable_flags = MOVABLE_FLAG_WHEELED
	initial_padding_material = /decl/material/solid/organic/cloth

/obj/structure/bed/chair/office/Move()
	. = ..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if (occupant && (src.loc != occupant.loc))
			if (propelled)
				for (var/mob/O in src.loc)
					if (O != occupant)
						Bump(O)
			else
				unbuckle_mob()

/obj/structure/bed/chair/office/Bump(atom/A)
	..()
	if(!buckled_mob)
		return

	if(propelled)
		var/mob/living/occupant = unbuckle_mob()

		var/def_zone = ran_zone()
		var/blocked = 100 * occupant.get_blocked_ratio(def_zone, BRUTE, damage = 10)
		occupant.throw_at(A, 3, propelled)
		occupant.apply_effect(6, STUN, blocked)
		occupant.apply_effect(6, WEAKEN, blocked) //#TODO: geez that might be a bit overkill
		occupant.apply_effect(6, STUTTER, blocked)
		occupant.apply_damage(10, BRUTE, def_zone)
		playsound(src.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		if(isliving(A))
			var/mob/living/victim = A
			def_zone = ran_zone()
			blocked = 100 * victim.get_blocked_ratio(def_zone, BRUTE, damage = 10)
			victim.apply_effect(6, STUN, blocked)
			victim.apply_effect(6, WEAKEN, blocked)  //#TODO: geez that might be a bit overkill
			victim.apply_effect(6, STUTTER, blocked)
			victim.apply_damage(10, BRUTE, def_zone)
		occupant.visible_message("<span class='danger'>[occupant] crashed into \the [A]!</span>")

/obj/structure/bed/chair/office/light
	initial_padding_color = "#f0f0f0"
/obj/structure/bed/chair/office/dark
	initial_padding_color = "#505050"

/obj/structure/bed/chair/office/comfy
	name = "comfy office chair"
	desc = "It's an office chair. It looks comfy."
	icon = 'icons/obj/structures/furniture/chair_comfy_office.dmi'

/obj/structure/bed/chair/office/comfy/unpadded
	initial_padding_material = null
/obj/structure/bed/chair/office/comfy/brown
	initial_padding_material = /decl/material/solid/organic/leather
/obj/structure/bed/chair/office/comfy/red
	initial_padding_color = "#9d2300"
/obj/structure/bed/chair/office/comfy/teal
	initial_padding_color = "#00e1ff"
/obj/structure/bed/chair/office/comfy/black
	initial_padding_color = "#505050"
/obj/structure/bed/chair/office/comfy/green
	initial_padding_color = "#b7f27d"
/obj/structure/bed/chair/office/comfy/purple
	initial_padding_color = "#9933ff"
/obj/structure/bed/chair/office/comfy/blue
	initial_padding_color = "#46698c"
/obj/structure/bed/chair/office/comfy/beige
	initial_padding_color = "#ceb689"
/obj/structure/bed/chair/office/comfy/lime
	initial_padding_color = "#62e36c"
/obj/structure/bed/chair/office/comfy/yellow
	initial_padding_color = "#ffbf00"

/obj/structure/bed/chair/rounded
	name = "rounded chair"
	desc = "It's a rounded chair. It looks comfy."
	icon = 'icons/obj/structures/furniture/chair_rounded.dmi'

/obj/structure/bed/chair/rounded/brown
	initial_padding_material = /decl/material/solid/organic/leather
/obj/structure/bed/chair/rounded/red
	initial_padding_color = "#9d2300"
/obj/structure/bed/chair/rounded/teal
	initial_padding_color = "#00e1ff"
/obj/structure/bed/chair/rounded/black
	initial_padding_color = "#505050"
/obj/structure/bed/chair/rounded/green
	initial_padding_color = "#b7f27d"
/obj/structure/bed/chair/rounded/purple
	initial_padding_color = "#9933ff"
/obj/structure/bed/chair/rounded/blue
	initial_padding_color = "#46698c"
/obj/structure/bed/chair/rounded/beige
	initial_padding_color = "#ceb689"
/obj/structure/bed/chair/rounded/lime
	initial_padding_color = "#62e36c"
/obj/structure/bed/chair/rounded/yellow
	initial_padding_color = "#ffbf00"

/obj/structure/bed/chair/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a sturdy-looking buckling system for smoother flights."
	icon = 'icons/obj/structures/furniture/chair_shuttle.dmi'
	buckle_sound = 'sound/effects/metal_close.ogg'
	material = /decl/material/solid/metal/steel
	initial_padding_material = /decl/material/solid/organic/cloth
	has_special_overlay = TRUE

/obj/structure/bed/chair/shuttle/get_base_icon()
	. = ..()
	if (buckled_mob)
		. += "_buckled"

/obj/structure/bed/chair/shuttle/blue
	initial_padding_color = "#46698c"
/obj/structure/bed/chair/shuttle/black
	initial_padding_color = "#505050"
/obj/structure/bed/chair/shuttle/white
	initial_padding_color = "#f0f0f0"

/obj/structure/bed/chair/wood
	name_prefix = "classic"
	desc = "Old is never too old to not be in fashion."
	icon = 'icons/obj/structures/furniture/chair_wooden.dmi'
	color = WOOD_COLOR_GENERIC
	material = /decl/material/solid/organic/wood/oak
	padding_extension_type = null // Cannot be padded.

/obj/structure/bed/chair/wood/mahogany
	color = WOOD_COLOR_RICH
	material = /decl/material/solid/organic/wood/mahogany
/obj/structure/bed/chair/wood/maple
	color = WOOD_COLOR_PALE
	material = /decl/material/solid/organic/wood/maple
/obj/structure/bed/chair/wood/ebony
	color = WOOD_COLOR_BLACK
	material = /decl/material/solid/organic/wood/ebony
/obj/structure/bed/chair/wood/walnut
	color = WOOD_COLOR_CHOCOLATE
	material = /decl/material/solid/organic/wood/walnut

/obj/structure/bed/chair/wood/wings
	name = "winged chair"
	icon = 'icons/obj/structures/furniture/chair_wooden_wings.dmi'

/obj/structure/bed/chair/wood/wings/mahogany
	color = WOOD_COLOR_RICH
	material = /decl/material/solid/organic/wood/mahogany
/obj/structure/bed/chair/wood/wings/maple
	color = WOOD_COLOR_PALE
	material = /decl/material/solid/organic/wood/maple
/obj/structure/bed/chair/wood/wings/ebony
	color = WOOD_COLOR_BLACK
	material = /decl/material/solid/organic/wood/ebony
/obj/structure/bed/chair/wood/wings/walnut
	color = WOOD_COLOR_CHOCOLATE
	material = /decl/material/solid/organic/wood/walnut

/obj/structure/bed/chair/backed
	name_prefix = "backed"
	desc = "A tall chair with a sturdy back. Not very comfortable."
	icon = 'icons/obj/structures/furniture/chair_backed.dmi'
	reinf_material = null
	material = /decl/material/solid/organic/wood/oak
	color = /decl/material/solid/organic/wood/oak::color

/obj/structure/bed/chair/backed/get_material_icon()
	return material?.backed_chair_icon || initial(icon)

/obj/structure/bed/chair/slatted
	name = "seat"
	name_prefix = "slatted" // slatted wooden seat vs wooden slatted seat
	icon = 'icons/obj/structures/furniture/chair_slatted.dmi'
	reinf_material = null
	material = /decl/material/solid/organic/wood/oak
	color = /decl/material/solid/organic/wood/oak::color

/obj/structure/bed/chair/slatted/get_material_icon()
	return material?.slatted_seat_icon || initial(icon)