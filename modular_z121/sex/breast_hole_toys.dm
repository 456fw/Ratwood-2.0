// ============================================================================
// modular_z121/sex/breast_hole_toys.dm
// 乳穴（Milk Hole）× 假阳具（Dildo / Toy）互动
// ----------------------------------------------------------------------------
// 复用 sexcon 既有的玩具 helper：
//   - get_dildo_in_either_hand(user)  手里拿着的假阳具
//   - get_dildo_on_belt(user)         腰带挂着的假阳具（可用于"戴具插入/pegging"）
//   - /obj/item/dildo/do_silver_check()  完成动作时的圣银/材料判定
// 这些 helper 定义在 code/datums/sexcon/sex_actions/toy/toy_helpers.dm。
// 台词风格与尾口动作一致：按力度档给出四段叙述式描写，不含任何操作提示。
// ============================================================================

// ----------------------------------------------------------------------------
// 自慰：用玩具插自己的乳穴（solo）
// ----------------------------------------------------------------------------
/datum/sex_action/toy_breast_hole
	name = "用玩具抽插自己的乳穴"
	user_sex_part = SEX_PART_BREAST_HOLE
	category = SEX_CATEGORY_PENETRATE
	solo = TRUE

/datum/sex_action/toy_breast_hole/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!(. = ..()))
		return FALSE
	if(!get_dildo_in_either_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/toy_breast_hole/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!(. = ..()))
		return FALSE
	if(!get_dildo_in_either_hand(user))
		return FALSE
	return TRUE

/datum/sex_action/toy_breast_hole/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/dildo/dildo = get_dildo_in_either_hand(user)
	var/start_message = "[user] 把[dildo]抵上自己的乳穴，慢慢送了进去。"
	if(breast_hole_is_lactating(user))
		start_message += " " + breast_hole_milk_start_line(user, "toy")
	user.visible_message(span_warning(start_message))
	playsound(user, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/toy_breast_hole/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/dildo/dildo = get_dildo_in_either_hand(user)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 握着[dildo]在自己的乳穴里缓缓抽送，冰凉的触感被体温一点点焐热。"
		if(SEX_FORCE_MID)
			message = "[user] 用[dildo]一下一下地插着自己的乳穴，软肉被撑开又合拢，泛起细密的水光。"
		if(SEX_FORCE_HIGH)
			message = "[user] 加快了手上的动作，[dildo]在自己的乳穴里又深又急地进出，呼吸也跟着乱起来。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 近乎失控地把[dildo]狠狠顶进自己的乳穴，搅得那处软肉发红发颤，几乎要含不住。"
	if(breast_hole_is_lactating(user))
		message += " " + breast_hole_milk_perform_line(user, user, user.sexcon.force, "toy")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.outercourse_noise(user, TRUE)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	user.sexcon.handle_passive_ejaculation()

	if(dildo)
		dildo.do_silver_check(user)

/datum/sex_action/toy_breast_hole/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/dildo/dildo = get_dildo_in_either_hand(user)
	var/finish_message = "[user] 把[dildo]从自己的乳穴里抽出，玩具上泛着一层湿光。"
	if(breast_hole_is_lactating(user))
		finish_message += " " + breast_hole_milk_finish_line(user, "toy")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/toy_breast_hole/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

// ----------------------------------------------------------------------------
// 手持有玩具：插对方的乳穴（pegging 子类使用腰带上的玩具）
// ----------------------------------------------------------------------------
/datum/sex_action/toy_other_breast_hole
	name = "用玩具抽插对方乳穴"
	category = SEX_CATEGORY_PENETRATE
	target_sex_part = SEX_PART_BREAST_HOLE
	var/pegging = FALSE

/datum/sex_action/toy_other_breast_hole/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!(. = ..()))
		return FALSE
	if(pegging)
		return get_dildo_on_belt(user)
	else
		return get_dildo_in_either_hand(user)

/datum/sex_action/toy_other_breast_hole/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!(. = ..()))
		return FALSE
	if(pegging)
		return get_dildo_on_belt(user)
	else
		return get_dildo_in_either_hand(user)

/datum/sex_action/toy_other_breast_hole/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/dildo/dildo = !pegging ? get_dildo_in_either_hand(user) : get_dildo_on_belt(user)
	var/start_message = "[user] 把[dildo]抵在 [target] 的乳穴口，缓缓推了进去。"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "toy")
	user.visible_message(span_warning(start_message))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/toy_other_breast_hole/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 用玩具在 [target] 的乳穴里轻轻抽送，穴口被磨得泛红，软肉一收一放地含着它。"
		if(SEX_FORCE_MID)
			message = "[user] 握着玩具稳定地进出 [target] 的乳穴，被撑开的肉壁泛起湿亮的水色。"
		if(SEX_FORCE_HIGH)
			message = "[user] 用玩具又快又重地操着 [target] 的乳穴，湿热的声响一声接一声。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 把玩具狠狠顶进 [target] 的乳穴最深处，搅得那处软肉发红发肿，几乎要合不拢。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "toy")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.outercourse_noise(target, TRUE)

	user.sexcon.perform_sex_action(target, 2, 4, TRUE)
	target.sexcon.handle_passive_ejaculation()

	var/obj/item/dildo/dildo = get_dildo_in_either_hand(user)
	if(dildo)
		dildo.do_silver_check(target)

/datum/sex_action/toy_other_breast_hole/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/dildo/dildo = !pegging ? get_dildo_in_either_hand(user) : get_dildo_on_belt(user)
	var/finish_message = "[user] 把[dildo]从 [target] 的乳穴里抽出，穴口一时没能合上。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "toy")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/toy_other_breast_hole/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE

/datum/sex_action/toy_other_breast_hole/pegging
	name = "用腰带假阳具抽插对方乳穴"
	pegging = TRUE

/datum/sex_action/toy_other_breast_hole/pegging/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 挺动腰胯，用腰带上的假阳具在 [target] 的乳穴里缓缓磨着。"
		if(SEX_FORCE_MID)
			message = "[user] 用腰带上的假阳具一下下顶进 [target] 的乳穴，把胸口顶得轻轻起伏。"
		if(SEX_FORCE_HIGH)
			message = "[user] 狠狠挺腰，用假阳具在 [target] 的乳穴里凶猛冲撞，撞出黏腻的水声。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 像是要把 [target] 操穿一样挺进乳穴，每一记都又深又重，逼得 [target] 几乎站不稳。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "toy")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.outercourse_noise(target, TRUE)
	user.sexcon.do_thrust_animate(target)

	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || (user.STASTR > 12))
		if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			user.sexcon.try_pelvis_crush(target)

	user.sexcon.perform_sex_action(target, 2.4, 7, FALSE)
	target.sexcon.handle_passive_ejaculation()

	var/obj/item/dildo/dildo = get_dildo_on_belt(user)
	if(dildo)
		dildo.do_silver_check(target)
