// ============================================================================
// modular_z121/sex/breast_hole_tailmaw.dm
// 乳穴（Milk Hole）× 尾口（Manticore Tail Maw）互动
// ----------------------------------------------------------------------------
// 复用既有的 /datum/sex_action/tailmaw 基类（modular/code/datums/sexcon/
//   sex_actions/tailmaw/_tailmaw.dm）：它负责显示条件、thrust 动画与极端内容检查。
// 尾口部位由 SEX_PART_TAIL_MAW 表示（需要 manticore 尾巴）；乳穴由
//   SEX_PART_BREAST_HOLE 表示（需要乳房器官的 has_milk_hole 标记）。
//
// 三个方向：
//   1. 尾巴插入对方的乳穴；
//   2. 尾口封住/吸吮对方的乳穴（哺乳中会吸走乳汁）；
//   3. 让对方用尾口服务自己的乳穴（接收方向）。
//
// 台词风格与既有尾口动作一致：持续动作按力度档给出不同描述，不含操作提示。
// ============================================================================

/// 尾口吸吮乳穴时，按概率把目标乳房里储存的乳汁吸走并喂给饮用者。
/// 逻辑与 oral/suck_nipples.dm 的吮乳段一致，只是把乳孔换成乳穴。
/datum/sex_action/tailmaw/proc/drain_breast_hole_milk(mob/living/carbon/human/drinker, mob/living/carbon/human/target)
	var/obj/item/organ/breasts/breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
	if(!breasts?.lactating)
		return
	var/milk_to_add = min(max(breasts.breast_size, 1), breasts.milk_stored)
	if(milk_to_add <= 0 || !prob(25))
		return
	drinker.reagents?.add_reagent(/datum/reagent/consumable/milk, milk_to_add)
	breasts.milk_stored -= milk_to_add
	to_chat(drinker, span_notice("我尝到了一丝奶香。"))
	to_chat(target, span_notice("我感觉乳汁从乳穴里渗了出来。"))

// ----------------------------------------------------------------------------
// 尾巴插入：用尾茎/尾塞插入对方的乳穴
// ----------------------------------------------------------------------------
/datum/sex_action/tailmaw/breast_hole_tailpeg
	name = "用尾巴插入对方乳穴"
	check_same_tile = FALSE
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_TAIL_MAW
	target_sex_part = SEX_PART_BREAST_HOLE

/datum/sex_action/tailmaw/breast_hole_tailpeg/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 抬起尾巴，将尾端的塞子抵在 [target] 的乳穴上，缓缓顶了进去！"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "tail")
	user.visible_message(span_warning(start_message))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 25, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailmaw/breast_hole_tailpeg/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 的尾巴在 [target] 的乳穴里缓缓进出，尾塞上细密的纹路轻柔地刮过柔软的内壁。"
		if(SEX_FORCE_MID)
			message = "[user] 把尾巴更深地送进 [target] 的乳穴，尾塞一边抽送一边缓缓扭转。"
		if(SEX_FORCE_HIGH)
			message = "[user] 的尾巴在 [target] 的乳穴里猛烈抽送，每一次顶入都让 [target] 的胸口随之起伏。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 像野兽一样用尾巴狠操 [target] 的乳穴，毫无顾忌地捣弄着那处软肉。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "tail")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(target, TRUE)

	user.sexcon.perform_sex_action(target, 2, 3, TRUE)
	user.sexcon.perform_sex_action(user, 1, 0, TRUE)
	user.sexcon.handle_passive_ejaculation(climax_part = SEX_PART_TAIL_MAW)

/datum/sex_action/tailmaw/breast_hole_tailpeg/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 的尾巴从 [target] 的乳穴里滑出，尾塞上泛着一层水光。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "tail")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/tailmaw/breast_hole_tailpeg/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return target.sexcon.finished_check()

// ----------------------------------------------------------------------------
// 尾口封住：把尾口压在对方乳穴上吸吮（含吮乳）
// ----------------------------------------------------------------------------
/datum/sex_action/tailmaw/breast_hole_maw
	name = "用尾口吸住对方的乳穴"
	check_same_tile = FALSE
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_TAIL_MAW
	target_sex_part = SEX_PART_BREAST_HOLE

/datum/sex_action/tailmaw/breast_hole_maw/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 的尾巴绽开，将尾口紧紧压合在 [target] 的乳穴上，细小的触须探出，舔舐着穴口边缘。"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "maw")
	user.visible_message(span_warning(start_message))
	playsound(target, 'sound/misc/mat/insert (1).ogg', 25, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailmaw/breast_hole_maw/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 的尾口贴着 [target] 的乳穴缓慢地吮动，触须懒洋洋地绕着穴口打转。"
		if(SEX_FORCE_MID)
			message = "[user] 尾口里的触须钻进 [target] 的乳穴，一边扭动一边被吸力缓缓往里带。"
		if(SEX_FORCE_HIGH)
			message = "[user] 的尾口用力嘬住 [target] 的乳穴，触须深探进去，吮吸声又响又湿。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 的尾口整个吞住 [target] 的乳穴，触须在里面横冲直撞，吸力贪婪得毫不留情。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "maw")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(target, TRUE)

	user.sexcon.perform_sex_action(target, 4, 1, TRUE)
	user.sexcon.perform_sex_action(user, 2, 0, FALSE)
	drain_breast_hole_milk(user, target)
	user.sexcon.handle_passive_ejaculation(climax_part = SEX_PART_TAIL_MAW)

/datum/sex_action/tailmaw/breast_hole_maw/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 的尾巴从 [target] 的乳穴上撕开，发出长长的一声湿响。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "maw")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/tailmaw/breast_hole_maw/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return target.sexcon.finished_check()

// ----------------------------------------------------------------------------
// 接收方向：让对方用尾口服务自己的乳穴（含对方的尾口吮乳）
// ----------------------------------------------------------------------------
/datum/sex_action/tailmaw/breast_hole_maw_receive
	name = "用对方的尾口套弄我的乳穴"
	check_same_tile = FALSE
	user_sex_part = SEX_PART_BREAST_HOLE
	target_sex_part = SEX_PART_TAIL_MAW

/datum/sex_action/tailmaw/breast_hole_maw_receive/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 牵引着 [target] 的尾巴，让尾口贴上自己的乳穴，在它合拢时轻叹出声。"
	if(breast_hole_is_lactating(user))
		start_message += " " + breast_hole_milk_start_line(user, "maw")
	user.visible_message(span_warning(start_message))
	playsound(user, 'sound/misc/mat/insert (1).ogg', 25, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailmaw/breast_hole_maw_receive/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[target] 的尾口贴着 [user] 的乳穴轻轻吮着，触须在里面好奇而轻柔地探索。"
		if(SEX_FORCE_MID)
			message = "[user] 把乳穴压上 [target] 的尾口，里面的触须以湿滑的节奏一阵阵抽送。"
		if(SEX_FORCE_HIGH)
			message = "[user] 用乳穴在 [target] 的尾口上起伏磨蹭，吮吸声贪得厉害，触须深深戳弄着。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 狠狠把乳穴压进 [target] 的尾口，吸力与触须一起绞紧，直到里面发烫发麻。"
	if(breast_hole_is_lactating(user))
		message += " " + breast_hole_milk_perform_line(user, target, user.sexcon.force, "maw")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(user, TRUE)

	user.sexcon.perform_sex_action(user, 3, 0, TRUE)
	user.sexcon.perform_sex_action(target, 2, 0, FALSE)
	drain_breast_hole_milk(target, user)
	target.sexcon.handle_passive_ejaculation(climax_part = SEX_PART_TAIL_MAW)

/datum/sex_action/tailmaw/breast_hole_maw_receive/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 把乳穴从 [target] 的尾口上拔开，发出「啵」的一声湿响。"
	if(breast_hole_is_lactating(user))
		finish_message += " " + breast_hole_milk_finish_line(user, "maw")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/tailmaw/breast_hole_maw_receive/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return user.sexcon.finished_check()
