
#define HARDSUIT_MIDDLE_CLICK 0
#define HARDSUIT_ALT_CLICK 1
#define HARDSUIT_CTRL_CLICK 2
#define MAX_HARDSUIT_CLICK_MODE 2

/client
	var/hardsuit_click_mode = HARDSUIT_MIDDLE_CLICK

/client/verb/toggle_hardsuit_mode()
	set name = "Toggle Hardsuit Activation Mode"
	set desc = "Switch between hardsuit activation modes."
	set category = "OOC"

	hardsuit_click_mode++
	if(hardsuit_click_mode > MAX_HARDSUIT_CLICK_MODE)
		hardsuit_click_mode = 0

	switch(hardsuit_click_mode)
		if(HARDSUIT_MIDDLE_CLICK)
			to_chat(src, "Hardsuit activation mode set to middle-click.")
		if(HARDSUIT_ALT_CLICK)
			to_chat(src, "Hardsuit activation mode set to alt-click.")
		if(HARDSUIT_CTRL_CLICK)
			to_chat(src, "Hardsuit activation mode set to control-click.")
		else
			// should never get here, but just in case:
			soft_assert(0, "Bad hardsuit click mode: [hardsuit_click_mode] - expected 0 to [MAX_HARDSUIT_CLICK_MODE]")
			to_chat(src, "Somehow you bugged the system. Setting your hardsuit mode to middle-click.")
			hardsuit_click_mode = HARDSUIT_MIDDLE_CLICK

/mob/living/MiddleClickOn(atom/A)
	if(client && client.hardsuit_click_mode == HARDSUIT_MIDDLE_CLICK)
		if(HardsuitClickOn(A))
			return
	..()

/mob/living/AltClickOn(atom/A)
	if(client && client.hardsuit_click_mode == HARDSUIT_ALT_CLICK)
		if(HardsuitClickOn(A))
			return
	..()

/mob/living/CtrlClickOn(atom/A)
	if(client && client.hardsuit_click_mode == HARDSUIT_CTRL_CLICK)
		if(HardsuitClickOn(A))
			return
	..()

/mob/living/proc/can_use_rig()
	return 0

/mob/living/carbon/human/can_use_rig()
	return 1

/mob/living/carbon/brain/can_use_rig()
	return istype(loc, /obj/item/mmi)

/mob/living/silicon/ai/can_use_rig()
	return carded

/mob/living/silicon/pai/can_use_rig()
	return loc == card

/mob/living/proc/HardsuitClickOn(var/atom/A, var/alert_ai = 0)
	if(!can_use_rig())
		return 0
	var/obj/item/rig/rig = get_rig()
	if(istype(rig) && !rig.offline && rig.selected_module)
		if(src != rig.wearer)
			if(rig.ai_can_move_suit(src, check_user_module = 1))
				message_admins("[key_name_admin(src, include_name = 1)] is trying to force \the [key_name_admin(rig.wearer, include_name = 1)] to use a hardsuit module.")
			else
				return 0
		rig.selected_module.engage(A, alert_ai)
		if(ismob(A)) // No instant mob attacking - though modules have their own cooldowns
			setClickCooldown(get_attack_speed())
		return 1
	return 0

#undef HARDSUIT_MIDDLE_CLICK
#undef HARDSUIT_ALT_CLICK
#undef HARDSUIT_CTRL_CLICK
#undef MAX_HARDSUIT_CLICK_MODE
