/obj/item/device/propaganda_chip
	name = "propaganda chip"
	icon_state = "implant_evil" //placeholder
	desc = "A delicate chip with an integrated speaker, you shouldn't disturb it"
	origin_tech = list(TECH_DATA  = 3)
	matter = list(MATERIAL_PLASTIC = 10, MATERIAL_STEEL = 5) //Needs to be a bit expensive so people cant spam messages
	var/active = FALSE
	var/last_talk_time = 0

/obj/item/device/propaganda_chip/verb/activate()
	set name = "Activate"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated() || !Adjacent(usr) || !isturf(loc))
		return

	for(var/obj/item/device/propaganda_chip/C in get_area(src))
		if (C.active)
			to_chat(usr, SPAN_WARNING("Another chip in the area prevents activation."))
			return

	active = TRUE
	anchored = TRUE
	START_PROCESSING(SSobj, src)
	to_chat(usr, SPAN_NOTICE("Chip activated and anchored to the ground, shouldn't be disturbed"))
	verbs -= .verb/activate
	verbs -= .verb/verb_pickup

obj/item/device/propaganda_chip/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/propaganda_chip/attack_hand(mob/user)
	if (active)
		switch(alert("Do I want to disturb the chip, it looks delicate","You think...","Yes","No"))
			if("Yes")
				if(!Adjacent(user))
					return
				visible_message(SPAN_WARNING("[user] destroys [src]!") )
				playsound(src.loc, 'sound/effects/basscannon.ogg', 100, 1, 15, 15)
				for (var/mob/M in range(20, src))
					to_chat(M,SPAN_WARNING("You hear a loud electronic noise"))

				Destroy()
			if("No")
				return
	..()

/obj/item/device/propaganda_chip/pickup()
	if (active)
		return
	..()

/obj/item/device/propaganda_chip/Process()
	if (active)
		if (world.time > last_talk_time + 20 SECONDS && prob(10)) // 4 times the time of the talking crystal, multiple chips can exist at once
			print_message()

/obj/item/device/propaganda_chip/proc/print_message()
	var/list/candidates = SSticker.minds.Copy()
	var/datum/mind/crew_target_mind
	while(candidates.len)
		var/datum/mind/candidate_mind = pick(candidates)
		candidates -= candidate_mind
		if(candidate_mind.assigned_role in list(JOBS_SECURITY))
			continue

		else
			crew_target_mind = candidate_mind

		if (crew_target_mind)
			break
	var/datum/mind/crew_name
	if (!crew_target_mind)
		crew_name = "Unknown"
	else
		crew_name = crew_target_mind.current.real_name

	var/list/messages = list( // Idealy should be extremely long with lots of lines
		"Watchmen searches just to take shit",
		"Blackshield just kills one a other with friendly fire",
		"With a paycheck no one can even afford 3 bread tubes...",
		"You know what to do... unionize",
		"Watchmen always use excessive force and brake bones",
		"An acter could beat blackshield in a shooting competition",
		"Command cares more about roaches and spiders than you",
		"Ian has more liberty than any of us",
		"Command gets more money than anyone and all they do is sit around or yell at people",
		"People can barely live paycheck to paycheck",
		"If Watchmens and blackshield are here to keep us safe, why do they kill themself and steal from us",
		"Why can Watchmens steal, well being in maints finding stuff is illegal",
		"Buget cuts always seem to make the workers life harder well the command never get affected by it",
		"If we buy a disk for printing ammo, why do we need to buy more disk to print more ammo",
		"We are tring to survive, the excelsior gear is better why not use it",
	)
	var/message_text = pick(messages)
	var/message = " <b>[crew_name]</b> says,<FONT SIZE =-2>  \"[message_text]\"</FONT>"

	for (var/mob/living/M in viewers(src))
		to_chat(M, "[message]")
	last_talk_time = world.time
