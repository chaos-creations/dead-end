/mob
	var/moving           = FALSE

/atom/movable/proc/SelfMove(var/direction)
	if(DoMove(direction, src) & MOVEMENT_HANDLED)
		return TRUE // Doesn't necessarily mean the atom physically moved

/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	. = current_posture.prone || ..() || !mover.density

/mob/proc/SetMoveCooldown(var/timeout)
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay)
	if(delay)
		delay.SetDelay(timeout)

/mob/proc/ExtraMoveCooldown(var/timeout)
	var/datum/movement_handler/mob/delay/delay = GetMovementHandler(/datum/movement_handler/mob/delay)
	if(delay)
		delay.AddDelay(timeout)

/client/proc/client_dir(input, direction=-1)
	return turn(input, direction*dir2angle(dir))

/client/Northeast()
	diagonal_action(NORTHEAST)
/client/Northwest()
	diagonal_action(NORTHWEST)
/client/Southeast()
	diagonal_action(SOUTHEAST)
/client/Southwest()
	diagonal_action(SOUTHWEST)

/client/proc/diagonal_action(direction)
	switch(client_dir(direction, 1))
		if(NORTHEAST)
			swap_hand()
			return
		if(SOUTHEAST)
			attack_self()
			return
		if(SOUTHWEST)
			if(isliving(usr))
				var/mob/living/M = usr
				M.toggle_throw_mode()
			else
				to_chat(usr, "<span class='warning'>This mob type cannot throw items.</span>")
			return
		if(NORTHWEST)
			mob.hotkey_drop()

/mob/proc/hotkey_drop()
	return FALSE

/mob/living/hotkey_drop()
	if(length(get_active_grabs()))
		. = TRUE
	else
		var/obj/item/hand = get_active_held_item()
		. = hand?.can_be_dropped_by_client(src)
	if(.)
		drop_item()

/client/verb/swap_hand()
	set hidden = 1
	if(ismob(mob))
		var/mob/M = mob
		M.swap_hand()
	if(isrobot(mob))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return

/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return

/client/verb/toggle_throw_mode_verb()
	set hidden = TRUE
	if(!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob.toggle_throw_mode()

//This proc should never be overridden elsewhere at /atom/movable to keep directions sane.
/atom/movable/Move(newloc, direct)
	if (direct & (direct - 1))
		if (direct & NORTH)
			if (direct & EAST)
				if (step(src, NORTH))
					step(src, EAST)
				else if (step(src, EAST))
					step(src, NORTH)
			else if (direct & WEST)
				if (step(src, NORTH))
					step(src, WEST)
				else if (step(src, WEST))
					step(src, NORTH)
		else
			if (direct & SOUTH)
				if (direct & EAST)
					if (step(src, SOUTH))
						step(src, EAST)
					else if (step(src, EAST))
						step(src, SOUTH)
				else if (direct & WEST)
					if (step(src, SOUTH))
						step(src, WEST)
					else if (step(src, WEST))
						step(src, SOUTH)
	else
		var/atom/A = src.loc

		var/olddir = dir //we can't override this without sacrificing the rest of movable/New()
		. = ..()
		if(direct != olddir)
			dir = olddir
			set_dir(direct)

		src.move_speed = world.time - src.l_move_time
		src.l_move_time = world.time
		src.m_flag = 1
		if ((A != src.loc && A && A.z == src.z))
			src.last_move = get_dir(A, src.loc)

	if(!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		space_drift(direct ? direct : last_move)

/client/Move(n, direction)
	if(!user_acted(src))
		return

	if(!mob)
		return // Moved here to avoid nullrefs below

	return mob.SelfMove(direction)

/mob/Process_Spacemove(allow_movement)
	if((. = ..()))
		return
	var/atom/backup = get_solid_footing()
	if(backup)
		if(istype(backup) && allow_movement)
			return backup
		return -1

/mob/living/Process_Spacemove(allow_movement)
	var/obj/item/tank/jetpack/thrust = get_jetpack()
	if(thrust?.on && (allow_movement || thrust.stabilization_on) && thrust.allow_thrust(0.01, src))
		return TRUE
	// This is horrible but short of spawning a jetpack inside the organ than locating
	// it, I don't really see another viable approach short of a total jetpack refactor.
	for(var/obj/item/organ/internal/powered/jets/jet in get_internal_organs())
		if(!jet.is_broken() && jet.active)
			// Unlike Bay, we don't check or unset inertia_dir here
			// because the spacedrift subsystem checks the return value of this proc
			// and unsets inertia_dir if it returns nonzero.
			return TRUE
	return ..()

/mob/proc/space_do_move(var/allow_move, var/direction)
	if(ismovable(allow_move))//push off things in space
		handle_space_pushoff(allow_move, direction)
		allow_move = -1
	return allow_move != -1 || !handle_spaceslipping()

/mob/proc/handle_space_pushoff(var/atom/movable/AM, var/direction)
	if(AM.anchored)
		return
	if(ismob(AM))
		var/mob/M = AM
		if(!M.can_slip(magboots_only = TRUE))
			return
	AM.inertia_ignore = src
	if(step(AM, turn(direction, 180)))
		to_chat(src, SPAN_INFO("You push off of \the [AM] to propel yourself."))
		inertia_ignore = AM

//return 1 if slipped, 0 otherwise
/mob/proc/handle_spaceslipping()
	var/slip_prob = slip_chance(10)
	world << "handling spaceslipping with prob [slip_prob]!"
	if(prob(skill_fail_chance(SKILL_EVA, slip_prob, SKILL_EXPERT)))
		to_chat(src, SPAN_DANGER("You slipped!"))
		step(src,turn(last_move, pick(45,-45)))
		return TRUE
	return FALSE

/mob/proc/slip_chance(var/prob_slip = 10)
	if(current_posture?.prone)
		return 0
	if(!can_slip(magboots_only = TRUE))
		return 0
	if(MOVING_DELIBERATELY(src))
		prob_slip *= 0.5
	return prob_slip

#define DO_MOVE(this_dir) var/final_dir = turn(this_dir, -dir2angle(dir)); Move(get_step(mob, final_dir), final_dir);

/client/verb/moveup()
	set name = ".moveup"
	set instant = 1
	DO_MOVE(NORTH)

/client/verb/movedown()
	set name = ".movedown"
	set instant = 1
	DO_MOVE(SOUTH)

/client/verb/moveright()
	set name = ".moveright"
	set instant = 1
	DO_MOVE(EAST)

/client/verb/moveleft()
	set name = ".moveleft"
	set instant = 1
	DO_MOVE(WEST)

#undef DO_MOVE

/mob/proc/set_next_usable_move_intent()
	var/checking_intent = (istype(move_intent) ? move_intent.type : move_intents[1])
	for(var/i = 1 to length(move_intents)) // One full iteration of the move set.
		checking_intent = next_in_list(checking_intent, move_intents)
		if(set_move_intent(GET_DECL(checking_intent)))
			return

/mob/proc/set_move_intent(var/decl/move_intent/next_intent)
	if(next_intent && move_intent != next_intent && next_intent.can_be_used_by(src))
		move_intent = next_intent
		if(istype(hud_used))
			hud_used.move_intent.icon_state = move_intent.hud_icon_state
		return TRUE
	return FALSE

/mob/proc/get_movement_datum_by_flag(var/move_flag = MOVE_INTENT_DELIBERATE)
	for(var/m_intent in move_intents)
		var/decl/move_intent/check_move_intent = GET_DECL(m_intent)
		if(check_move_intent.flags & move_flag)
			return check_move_intent

/mob/proc/get_movement_datum_by_missing_flag(var/move_flag = MOVE_INTENT_DELIBERATE)
	for(var/m_intent in move_intents)
		var/decl/move_intent/check_move_intent = GET_DECL(m_intent)
		if(!(check_move_intent.flags & move_flag))
			return check_move_intent

/mob/proc/get_movement_datums_by_flag(var/move_flag = MOVE_INTENT_DELIBERATE)
	. = list()
	for(var/m_intent in move_intents)
		var/decl/move_intent/check_move_intent = GET_DECL(m_intent)
		if(check_move_intent.flags & move_flag)
			. += check_move_intent

/mob/proc/get_movement_datums_by_missing_flag(var/move_flag = MOVE_INTENT_DELIBERATE)
	. = list()
	for(var/m_intent in move_intents)
		var/decl/move_intent/check_move_intent = GET_DECL(m_intent)
		if(!(check_move_intent.flags & move_flag))
			. += check_move_intent

/mob/verb/SetDefaultWalk()
	set name = "Set Default Walk"
	set desc = "Select your default walking style."
	set category = "IC"
	var/choice = input(usr, "Select a default walk.", "Set Default Walk") as null|anything in get_movement_datums_by_missing_flag(MOVE_INTENT_QUICK)
	if(choice && (choice in get_movement_datums_by_missing_flag(MOVE_INTENT_QUICK)))
		default_walk_intent = choice
		to_chat(src, SPAN_NOTICE("You will now default to [default_walk_intent] when moving deliberately."))

/mob/verb/SetDefaultRun()
	set name = "Set Default Run"
	set desc = "Select your default running style."
	set category = "IC"
	var/choice = input(usr, "Select a default run.", "Set Default Run") as null|anything in get_movement_datums_by_flag(MOVE_INTENT_QUICK)
	if(choice && (choice in get_movement_datums_by_flag(MOVE_INTENT_QUICK)))
		default_run_intent = choice
		to_chat(src, SPAN_NOTICE("You will now default to [default_run_intent] when moving quickly."))

/client/verb/setmovingslowly()
	set hidden = 1
	if(mob)
		mob.set_moving_slowly()

/mob/proc/set_moving_slowly()
	if(!default_walk_intent)
		default_walk_intent = get_movement_datum_by_missing_flag(MOVE_INTENT_QUICK)
	if(default_walk_intent && move_intent != default_walk_intent)
		set_move_intent(default_walk_intent)

/client/verb/setmovingquickly()
	set hidden = 1
	if(mob)
		mob.set_moving_quickly()

/mob/proc/set_moving_quickly()
	if(!default_run_intent)
		default_run_intent = get_movement_datum_by_flag(MOVE_INTENT_QUICK)
	if(default_run_intent && move_intent != default_run_intent)
		set_move_intent(default_run_intent)

/mob/proc/can_sprint()
	return TRUE

/mob/proc/adjust_stamina(var/amt)
	return

/mob/proc/get_stamina()
	return 100
