/decl/psionic_faculty/psychokinesis
	id = PSI_PSYCHOKINESIS
	name = "Psychokinesis"
	associated_intent_flag = I_FLAG_GRAB
	armour_types = list(ARMOR_MELEE, ARMOR_BULLET)

/decl/psionic_power/psychokinesis
	faculty = PSI_PSYCHOKINESIS
	use_manifest = TRUE
	use_sound = null
	abstract_type = /decl/psionic_power/psychokinesis

/decl/psionic_power/psychokinesis/psiblade
	name =            "Psiblade"
	cost =            10
	cooldown =        30
	min_rank =        PSI_RANK_OPERANT
	use_description = "Click on or otherwise activate an empty hand while on harm intent to manifest a psychokinetic cutting blade. The power the blade will vary based on your mastery of the faculty."
	admin_log = FALSE

/decl/psionic_power/psychokinesis/psiblade/invoke(var/mob/living/user, var/mob/living/target)
	if((target && user != target) || !user.check_intent(I_FLAG_HARM))
		return FALSE
	. = ..()
	if(.)
		var/datum/ability_handler/psionics/psi = user?.get_ability_handler(/datum/ability_handler/psionics)
		switch(psi?.get_rank(faculty))
			if(PSI_RANK_PARAMOUNT)
				return new /obj/item/ability/psionic/psiblade/master/grand/paramount(user, user)
			if(PSI_RANK_GRANDMASTER)
				return new /obj/item/ability/psionic/psiblade/master/grand(user, user)
			if(PSI_RANK_MASTER)
				return new /obj/item/ability/psionic/psiblade/master(user, user)
			else
				return new /obj/item/ability/psionic/psiblade(user, user)

/decl/psionic_power/psychokinesis/tinker
	name =            "Tinker"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_MASTER
	use_description = "Click on or otherwise activate an empty hand while on help intent to manifest a psychokinetic tool. Use it in-hand to switch between tool types."
	admin_log = FALSE

/decl/psionic_power/psychokinesis/tinker/invoke(var/mob/living/user, var/mob/living/target)
	if((target && user != target) || !user.check_intent(I_FLAG_HELP))
		return FALSE
	. = ..()
	if(.)
		return new /obj/item/ability/psionic/tinker(user)

/decl/psionic_power/psychokinesis/telekinesis
	name =            "Telekinesis"
	cost =            5
	cooldown =        10
	use_ranged =      TRUE
	use_manifest =    FALSE
	min_rank =        PSI_RANK_GRANDMASTER
	use_description = "Click on a distant target while on grab intent to manifest a psychokinetic grip. Use it manipulate objects at a distance."
	admin_log = FALSE
	use_sound = 'sound/effects/psi/power_used.ogg'
	var/static/list/valid_machine_types = list(
		/obj/machinery/door
	)

/decl/psionic_power/psychokinesis/telekinesis/invoke(var/mob/living/user, var/mob/living/target)
	if(!user.check_intent(I_FLAG_GRAB))
		return FALSE
	. = ..()
	if(.)

		var/distance = get_dist(user, target)
		var/datum/ability_handler/psionics/psi = user?.get_ability_handler(/datum/ability_handler/psionics)
		if(distance > psi?.get_rank(PSI_PSYCHOKINESIS))
			to_chat(user, "<span class='warning'>Your telekinetic power won't reach that far.</span>")
			return FALSE

		if(ismob(target) || istype(target, /obj))
			var/obj/item/ability/psionic/telekinesis/tk = new(user)
			if(tk.set_focus(target))
				tk.sparkle()
				user.visible_message(SPAN_NOTICE("\The [user] reaches out."))
				return tk
		else if(istype(target, /obj/structure))
			user.visible_message(SPAN_NOTICE("\The [user] makes a strange gesture."))
			var/obj/O = target
			O.attack_hand(user) // We bypass adjacency checks due to telekinetics.
			return TRUE
		else if(istype(target, /obj/machinery))
			for(var/mtype in valid_machine_types)
				if(istype(target, mtype))
					var/obj/machinery/machine = target
					machine.attack_hand(user) // We bypass adjacency checks due to telekinetics.
					return TRUE
	return FALSE
