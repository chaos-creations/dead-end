/obj/screen/intent/diona_nymph
	icon = 'mods/mobs/dionaea/icons/ui.dmi'
	icon_state = "intent_devour"
	screen_loc = DIONA_SCREEN_LOC_INTENT

/obj/screen/intent/diona_nymph/on_update_icon()
	if(intent == I_HURT || intent == I_GRAB)
		intent = I_GRAB
		icon_state = "intent_expel"
	else
		intent = I_DISARM
		icon_state = "intent_devour"

/obj/screen/diona
	icon = 'mods/mobs/dionaea/icons/ui.dmi'

/obj/screen/diona/hat
	name = "equipped hat"
	screen_loc = DIONA_SCREEN_LOC_HAT
	icon_state = "hat"

/obj/screen/diona/hat/Click()
	var/datum/extension/hattable/hattable = get_extension(usr, /datum/extension/hattable)
	hattable?.drop_hat(usr)

/obj/screen/diona/held
	name = "held item"
	screen_loc =  DIONA_SCREEN_LOC_HELD
	icon_state = "held"

/obj/screen/diona/held/Click()
	var/mob/living/carbon/alien/diona/chirp = usr
	if(istype(chirp) && chirp.holding_item) chirp.unEquip(chirp.holding_item)

/datum/hud/diona_nymph
	var/obj/screen/diona/hat/hat
	var/obj/screen/diona/held/held

/datum/hud/diona_nymph/get_ui_style()
	return 'mods/mobs/dionaea/icons/ui.dmi'

/datum/hud/diona_nymph/get_ui_color()
	return COLOR_WHITE

/datum/hud/diona_nymph/get_ui_alpha()
	return 255

/datum/hud/diona_nymph/FinalizeInstantiation()

	src.adding = list()
	src.other = list()

	hat = new
	adding += hat

	held = new
	adding += held

	action_intent = new /obj/screen/intent/diona_nymph()
	adding += action_intent

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'mods/mobs/dionaea/icons/ui.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.SetName("health")
	mymob.healths.screen_loc = DIONA_SCREEN_LOC_HEALTH

	mymob.client.screen = list(mymob.healths)
	mymob.client.screen += src.adding + src.other
