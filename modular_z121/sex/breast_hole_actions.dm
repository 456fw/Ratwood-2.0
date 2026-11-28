// ============================================================================
// modular_z121/sex/breast_hole_actions.dm
// 乳穴（Milk Hole）ERP 动作（阴茎 / 手指 / 口 / 强制）
// ----------------------------------------------------------------------------
// 需求：角色在「Features → Breasts」里把「Milk hole」选为 YES 后，会在胸部得到
//   一个可插入的开口；执行该选择的角色在 ERP 面板（Sate Desire）中会多出下列动作。
//
// 数据来源：/obj/item/organ/breasts 的 has_milk_hole 字段。它由角色定制项
//   /datum/customizer_entry/organ/breasts 经 organ DNA 在角色生成时写入器官。
//   ERP 的通用部位检查在 code/datums/sexcon/sex_action.dm 中通过
//   SEX_PART_BREAST_HOLE（code/__DEFINES/sexcon_defines.dm）完成，本文件只写动作本身。
//
//
//   若承受方（或自慰时本人）正在泌乳，会额外追加一段乳汁描写（见下方 helper）。
//
// 重要：乳穴不是可"结（knot）"的部位。以下所有动作都 **不** 设置 knot_on_finish，
//   也不会向 cum_into 传 knot_* 参数；否则结部系统会错误地把结打进胸部。
//
// 注册方式：GLOB.sex_actions = typesof(/datum/sex_action)，本文件的每个具体类型
//   都会在初始化时自动进入面板，无需手工登记。
// ============================================================================


// ----------------------------------------------------------------------------
// 乳汁辅助：判断是否泌乳 / 生成各阶段的乳汁描写
// 这些 proc 是全局的，toys 与 tailmaw 文件也会复用。
// ----------------------------------------------------------------------------

/// 角色是否正在泌乳（有乳房器官且 lactating）。乳穴的乳汁台词只在此时追加。
/proc/breast_hole_is_lactating(mob/living/carbon/human/H)
	if(!ishuman(H))
		return FALSE
	var/obj/item/organ/breasts/breasts = H.getorganslot(ORGAN_SLOT_BREASTS)
	return breasts?.lactating

/// 动作开始时的乳汁补充描写。
/proc/breast_hole_milk_start_line(mob/living/carbon/human/owner, context = "fuck")
	if(context == "self")
		return pick(list(
			"[owner] 的乳穴被指尖一碰，一缕乳白的乳汁先渗了出来。",
			"穴口泛起一点乳白，温热的乳汁正慢慢往外渗。",
		))
	if(context == "double")
		return pick(list(
			"[owner] 的两个乳穴被同时挤得一缩，乳白的乳汁从两边穴口一起渗了出来。",
			"左右两处穴口同时泛起乳白，温热的乳汁慢慢往外渗。",
		))
	return pick(list(
		"[owner] 的乳穴被挤得一缩，一缕乳白的乳汁先从穴口渗了出来。",
		"穴口泛起一点乳白，温热的乳汁正慢慢往外渗。",
	))

/// 持续动作时的乳汁补充描写。按力度轻重分成两组，由 context 选择动作场景。
/proc/breast_hole_milk_perform_line(mob/living/carbon/human/owner, mob/living/carbon/human/partner, force, context = "fuck")
	var/heavy = force >= SEX_FORCE_HIGH
	var/list/lines
	switch(context)
		if("double")
			lines = heavy ? list(
				"两边的乳穴一起被操得发颤，乳汁顺着 [owner] 的乳肉两边往下流。",
				"两根肉棒把两个乳穴都撑得发红，乳汁混着体液从两边往外冒。",
			) : list(
				"两个乳穴都泛起乳白，乳汁随着抽送一点点从两边渗出来。",
				"左右两处穴口都被磨得湿亮，乳汁一滴滴向下淌。",
			)
		if("ride")
			lines = heavy ? list(
				"[owner] 每起伏一次，乳穴就挤出一小股乳汁，顺着 [partner] 的小腹往下滑。",
				"[owner] 骑得越急，乳汁被挤得越凶，沿着 [partner] 身上到处流淌。",
			) : list(
				"[owner] 轻轻起伏，乳穴里的乳汁一点点渗出来，落在 [partner] 的小腹上。",
				"[owner] 的穴口泛着湿亮，乳汁随着起伏一滴滴淌下来。",
			)
		if("finger")
			lines = heavy ? list(
				"手指把乳汁从乳穴里一点点挤出来，顺着指节往下滴。",
				"乳穴被搅得发软，乳汁顺着 [owner] 的胸口往下流。",
			) : list(
				"指缝里除了黏液，还沾着一丝乳白。",
				"手指搅动时，乳汁从穴口一点点渗了出来。",
			)
		if("suck")
			lines = heavy ? list(
				"乳汁多得来不及咽，混着唾液从唇角溢了出来。",
				"[owner] 的乳穴被吸得一阵收缩，乳汁一股股涌进嘴里。",
			) : list(
				"温热的乳汁先一步渗进嘴里，被一口口咽下。",
				"一边吮吸一边吞咽，乳汁的甜香在口里化开。",
			)
		if("toy")
			lines = heavy ? list(
				"玩具把乳汁挤得往外冒，顺着 [owner] 的胸口往下淌。",
				"乳穴被玩具撑得发红，乳汁从缝隙里被带出来。",
			) : list(
				"玩具抽送时把乳汁带了出来，顺着玩具往下淌。",
				"穴口泛着乳白，乳汁一点点渗出来。",
			)
		if("tail")
			lines = heavy ? list(
				"尾塞顶得又深又急，乳汁被撞得从乳穴里喷出来。",
				"乳穴被尾巴操得发颤，乳汁顺着 [owner] 的乳肉流下来。",
			) : list(
				"尾塞缓慢抽送，把乳汁一点点挤了出来。",
				"乳穴被磨得发软，乳汁顺着穴口往下淌。",
			)
		if("maw")
			lines = heavy ? list(
				"尾口贪婪地吸着，乳汁被源源不断地吸走，吞咽声混在吮吸声里。",
				"触须把乳汁一股股勾出来，尾口吮得更急。",
			) : list(
				"尾口把乳汁一点点吸了出来，湿热的吮吸声绵密不断。",
				"触须在乳穴里搅动，把乳汁一点点带了出来。",
			)
		if("self")
			lines = heavy ? list(
				"自己的乳穴被弄得发软，乳汁顺着指节往下滴。",
				"指间满是乳白的乳汁，顺着胸口一路淌下。",
			) : list(
				"指间很快沾上乳白的乳汁，穴口泛着湿亮。",
				"自己的乳穴被慢慢揉开，乳汁一点点渗了出来。",
			)
		else // "fuck"
			lines = heavy ? list(
				"乳汁混着体液被一次次挤出来，湿了 [owner] 和 [partner] 的胸口。",
				"每一下冲撞都把乳汁撞得往外冒，顺着 [owner] 的乳肉四下流淌。",
			) : list(
				"乳汁顺着 [owner] 的乳穴边缘渗了出来，沿着胸口往下淌。",
				"每一次抽送都带出乳白的乳汁，[owner] 的穴口泛着湿亮的光。",
			)
	return pick(lines)

/// 高潮/射精时的乳汁补充描写。
/proc/breast_hole_milk_ejac_line(mob/living/carbon/human/owner, context = "fuck")
	if(context == "double")
		return pick(list(
			"混着乳汁的白浊随即从两边穴口一起溢了出来。",
			"滚烫的精液把两个乳穴里的乳汁一并顶了出来，从两边往外冒。",
		))
	return pick(list(
		"混着乳汁的白浊随即从穴口溢了出来。",
		"滚烫的精液把乳汁一并顶了出来，顺着乳穴往外冒。",
	))

/// 动作结束时的乳汁补充描写。
/proc/breast_hole_milk_finish_line(mob/living/carbon/human/owner, context = "fuck")
	if(context == "self")
		return pick(list(
			"穴口一松，乳汁混着体液从乳穴里淌了出来。",
			"乳白的乳汁顺着 [owner] 的胸口滑下，留下一道湿痕。",
		))
	if(context == "double")
		return pick(list(
			"两边穴口一松，乳汁混着体液同时从两个乳穴里淌了出来。",
			"乳白的乳汁顺着 [owner] 的两边胸口滑下，各留下一道湿痕。",
		))
	return pick(list(
		"穴口一松，乳汁混着体液从乳穴里淌了出来。",
		"乳白的乳汁顺着 [owner] 的胸口滑下，留下一道湿痕。",
	))


// ----------------------------------------------------------------------------
// 插入：用阴茎插入目标的乳穴（双屌版见下方 /double）
// ----------------------------------------------------------------------------
/datum/sex_action/breast_hole_sex
	name = "抽插对方乳穴"
	stamina_cost = 1.0
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_COCK
	user_needs_functional = TRUE
	target_sex_part = SEX_PART_BREAST_HOLE

/datum/sex_action/breast_hole_sex/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 扶着自己的阴茎抵上 [target] 的乳穴，缓慢而坚定地顶了进去，柔软的穴口被撑开，紧紧含住了前端。"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "fuck")
	user.visible_message(span_warning(start_message))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/breast_hole_sex/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 浅浅地在 [target] 的乳穴里抽送，穴口被磨得泛红，每一次退出都牵出一丝黏腻的水光。"
		if(SEX_FORCE_MID)
			message = "[user] 的阴茎在 [target] 的乳穴里稳定地进出，柔软的内壁被撑得饱满，胸口随着节奏轻轻起伏。"
		if(SEX_FORCE_HIGH)
			message = "[user] 猛烈地捣弄着 [target] 的乳穴，肉壁被撞得发颤，湿热的吮吸声一声盖过一声。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 像失了控一样狠操 [target] 的乳穴，每一下都顶到最深处，把 [target] 的胸口撞得直抖。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "fuck")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(target, TRUE)
	user.sexcon.do_thrust_animate(target)

	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || (user.STASTR > 12))
		if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			user.sexcon.try_pelvis_crush(target)

	user.sexcon.perform_sex_action(user, 2, 0, TRUE)
	if(user.sexcon.check_active_ejaculation())
		var/ejac_message = "[user] 闷哼一声，把滚烫的精液尽数射进 [target] 的乳穴！"
		if(breast_hole_is_lactating(target))
			ejac_message += " " + breast_hole_milk_ejac_line(target)
		user.visible_message(span_love(ejac_message))
		for(var/i = 1; i <= user.sexcon.get_load_bursts(); i++)
			user.sexcon.cum_into(splashed_user = target, orifice = SEX_PART_BREAST_HOLE, skip_knot_try = TRUE, consume_charge = i == 1 ? TRUE : FALSE)
			sleep(10)

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.2, 3, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.4, 7, FALSE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/breast_hole_sex/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 缓缓抽出阴茎，乳穴被带得微微张开，里面积着的白浊沿着胸口滑下。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "fuck")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/breast_hole_sex/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

// ----------------------------------------------------------------------------
// 插入（双屌）：两根肉棒分别插入左右两个乳穴，只有拥有双屌的角色才显示
// ----------------------------------------------------------------------------
/datum/sex_action/breast_hole_sex/double
	name = "用双根肉棒分别抽插对方两个乳穴"

/datum/sex_action/breast_hole_sex/double/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!user.sexcon.double_penis_type())
		return FALSE
	return ..()

/datum/sex_action/breast_hole_sex/double/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!user.sexcon.double_penis_type())
		return FALSE
	return ..()

/datum/sex_action/breast_hole_sex/double/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 把两根肉棒分别对准 [target] 左右两个乳穴，缓缓顶了进去，两处穴口同时被撑开。"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "double")
	user.visible_message(span_warning(start_message))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/breast_hole_sex/double/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 的两根肉棒在 [target] 的两个乳穴里一左一右地缓慢抽送，软肉各自含吮着它们。"
		if(SEX_FORCE_MID)
			message = "[user] 让双屌分别在 [target] 的两个乳穴里交替进出，撑满的胀感从两边同时涌上来。"
		if(SEX_FORCE_HIGH)
			message = "[user] 用力抽送着 [target] 的两个乳穴，两根肉棒一进一出，把两边胸口都撞得发颤。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 近乎粗暴地把两根肉棒分别顶进 [target] 的两个乳穴深处，撑得两处软肉都合不拢。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "double")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(target, TRUE)
	user.sexcon.do_thrust_animate(target)

	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || (user.STASTR > 12))
		if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			user.sexcon.try_pelvis_crush(target)

	user.sexcon.perform_sex_action(user, 2, 0, TRUE)
	if(user.sexcon.check_active_ejaculation())
		var/ejac_message = "[user] 两根肉棒先后泄出，把滚烫的精液分别灌进 [target] 的两个乳穴！"
		if(breast_hole_is_lactating(target))
			ejac_message += " " + breast_hole_milk_ejac_line(target, "double")
		user.visible_message(span_love(ejac_message))
		for(var/i = 1; i <= user.sexcon.get_load_bursts(); i++)
			user.sexcon.cum_into(splashed_user = target, orifice = SEX_PART_BREAST_HOLE, skip_knot_try = TRUE, consume_charge = i == 1 ? TRUE : FALSE)
			sleep(10)

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.2, 3, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.4, 11, FALSE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/breast_hole_sex/double/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 抽出双屌，两个乳穴被撑出的形状一时都没合上，白浊从两边穴口往外淌。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "double")
	user.visible_message(span_warning(finish_message))

// ----------------------------------------------------------------------------
// 骑乘：用户用自己的乳穴骑乘目标的阴茎
// ----------------------------------------------------------------------------
/datum/sex_action/breast_hole_ride
	name = "用乳穴骑乘对方"
	stamina_cost = 1.0
	aggro_grab_instead_same_tile = FALSE
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_BREAST_HOLE
	target_sex_part = SEX_PART_COCK

/datum/sex_action/breast_hole_ride/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 把自己的乳穴对准 [target] 的阴茎，咬着唇缓缓坐下去，湿热的内壁一寸寸将它吞没。"
	if(breast_hole_is_lactating(user))
		start_message += " " + breast_hole_milk_start_line(user, "ride")
	user.visible_message(span_warning(start_message))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/breast_hole_ride/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 在 [target] 身上轻轻起伏，乳穴含着阴茎慢慢磨蹭，湿热的软肉一下一下地收紧。"
		if(SEX_FORCE_MID)
			message = "[user] 扶着 [target] 的肩，用乳穴一下一下地吞吐着，腰肢摆得又软又黏。"
		if(SEX_FORCE_HIGH)
			message = "[user] 骑得越来越急，乳穴狠狠套弄着 [target]，胸口随着动作不住地晃。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 几乎失控地起伏着，把 [target] 深深吃进乳穴里，水声和喘息混在一起再也压不住。"
	if(breast_hole_is_lactating(user))
		message += " " + breast_hole_milk_perform_line(user, target, user.sexcon.force, "ride")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(user, TRUE)
	user.sexcon.do_thrust_animate(target)

	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || (user.STASTR > 12))
		if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			user.sexcon.try_pelvis_crush(target)

	target.sexcon.perform_sex_action(target, 2, 0, TRUE, involved_penis = target.getorganslot(ORGAN_SLOT_PENIS))
	if(target.sexcon.check_active_ejaculation())
		var/ejac_message = "[target] 猛地绷紧，把滚烫的精液射进 [user] 的乳穴！"
		if(breast_hole_is_lactating(user))
			ejac_message += " " + breast_hole_milk_ejac_line(user)
		target.visible_message(span_love(ejac_message))
		for(var/i = 1; i <= target.sexcon.get_load_bursts(); i++)
			sleep(10)
			target.sexcon.cum_into(splashed_user = user, orifice = SEX_PART_BREAST_HOLE, skip_knot_try = TRUE, consume_charge = i == 1 ? TRUE : FALSE)

	if(target.sexcon.considered_limp())
		target.sexcon.perform_sex_action(user, 1.2, 3, FALSE, involved_penis = target.getorganslot(ORGAN_SLOT_PENIS))
	else
		target.sexcon.perform_sex_action(user, 2.4, 7, FALSE, involved_penis = target.getorganslot(ORGAN_SLOT_PENIS))
	user.sexcon.handle_passive_ejaculation()

/datum/sex_action/breast_hole_ride/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 喘息着抬起腰，乳穴离开时牵出一道湿亮的丝，白浊顺着胸口滑落。"
	if(breast_hole_is_lactating(user))
		finish_message += " " + breast_hole_milk_finish_line(user, "ride")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/breast_hole_ride/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

// ----------------------------------------------------------------------------
// 手指：用手指插入目标的乳穴
// ----------------------------------------------------------------------------
/datum/sex_action/breast_hole_finger
	name = "指弄对方乳穴"
	check_same_tile = FALSE
	category = SEX_CATEGORY_HANDS
	target_sex_part = SEX_PART_BREAST_HOLE

/datum/sex_action/breast_hole_finger/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 用指腹揉开 [target] 的乳穴，慢慢把手指探了进去。"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "finger")
	user.visible_message(span_warning(start_message), vision_distance = (user.sexcon.do_subtle_action ? 1 : DEFAULT_MESSAGE_RANGE))
	user.sexcon.show_progress = 0

/datum/sex_action/breast_hole_finger/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/do_subtle = user.sexcon.do_subtle_action
	user.sexcon.show_progress = !do_subtle
	user.sexcon.suppress_moan = target.sexcon.suppress_moan = do_subtle

	var/message
	if(do_subtle)
		message = "[user] 不声不响地把手指探进 [target] 的乳穴，在衣料遮掩下悄悄抽送着。"
	else
		switch(user.sexcon.force)
			if(SEX_FORCE_LOW)
				message = "[user] 的手指在 [target] 的乳穴里轻轻抽送，指节被柔软的内壁细细含吮着。"
			if(SEX_FORCE_MID)
				message = "[user] 屈起指节，在 [target] 的乳穴里按弄搅动，湿热的肉壁被勾得一阵阵发紧。"
			if(SEX_FORCE_HIGH)
				message = "[user] 的手指又快又深地抽插着 [target] 的乳穴，黏腻的水声从指缝里溢出来。"
			if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
				message = "[user] 狠狠地把手指顶进 [target] 的乳穴深处，搅得那处软肉又红又肿，几乎要绞住指节。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "finger")
	user.sexcon_action_message(user.sexcon.spanify_force(message), vision_distance = (do_subtle ? 1 : DEFAULT_MESSAGE_RANGE))
	if(!do_subtle)
		user.sexcon.generic_sex_noise()

	user.sexcon.perform_sex_action(target, 2, 4, TRUE)

	target.sexcon.handle_passive_ejaculation()

	user.sexcon.suppress_moan = target.sexcon.suppress_moan = FALSE

/datum/sex_action/breast_hole_finger/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 把手指抽出来，指尖沾着黏腻的水光。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "finger")
	user.visible_message(span_warning(finish_message), vision_distance = (user.sexcon.do_subtle_action ? 1 : DEFAULT_MESSAGE_RANGE))

/datum/sex_action/breast_hole_finger/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE

// ----------------------------------------------------------------------------
// 自慰：用手指插自己的乳穴（solo）
// ----------------------------------------------------------------------------
/datum/sex_action/masturbate_breast_hole
	name = "指弄自己的乳穴"
	category = SEX_CATEGORY_HANDS
	user_sex_part = SEX_PART_BREAST_HOLE
	solo = TRUE

/datum/sex_action/masturbate_breast_hole/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 用指尖抵住自己的乳穴，缓缓探了进去。"
	if(breast_hole_is_lactating(user))
		start_message += " " + breast_hole_milk_start_line(user, "self")
	user.visible_message(span_warning(start_message), vision_distance = (user.sexcon.do_subtle_action ? 1 : DEFAULT_MESSAGE_RANGE))
	user.sexcon.show_progress = 0

/datum/sex_action/masturbate_breast_hole/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/do_subtle = user.sexcon.do_subtle_action
	user.sexcon.show_progress = !do_subtle
	user.sexcon.suppress_moan = do_subtle

	var/message
	if(do_subtle)
		message = "[user] 悄悄把手指探进自己的乳穴，隔着衣料不动声色地抽送着。"
	else
		switch(user.sexcon.force)
			if(SEX_FORCE_LOW)
				message = "[user] 用手指在自己的乳穴里慢慢挑弄，软肉被磨得又热又痒。"
			if(SEX_FORCE_MID)
				message = "[user] 屈起指节，把自己的乳穴搅得湿软发烫，细微的水声在指间响起。"
			if(SEX_FORCE_HIGH)
				message = "[user] 手指又快又急地抽插着自己的乳穴，呼吸越来越乱，胸口起伏得厉害。"
			if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
				message = "[user] 近乎失控地把手指狠狠顶进自己的乳穴，搅得那处软肉发麻发颤，几乎要绞住指节。"
	if(breast_hole_is_lactating(user))
		message += " " + breast_hole_milk_perform_line(user, user, user.sexcon.force, "self")
	user.sexcon_action_message(user.sexcon.spanify_force(message), vision_distance = (do_subtle ? 1 : DEFAULT_MESSAGE_RANGE))

	user.sexcon.perform_sex_action(user, 1, 4, TRUE)
	user.sexcon.handle_passive_ejaculation()

	user.sexcon.suppress_moan = FALSE

/datum/sex_action/masturbate_breast_hole/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 把手指从自己的乳穴里抽出，指尖泛着水光。"
	if(breast_hole_is_lactating(user))
		finish_message += " " + breast_hole_milk_finish_line(user, "self")
	user.visible_message(span_warning(finish_message), vision_distance = (user.sexcon.do_subtle_action ? 1 : DEFAULT_MESSAGE_RANGE))

/datum/sex_action/masturbate_breast_hole/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

// ----------------------------------------------------------------------------
// 吸吮：用嘴吸吮目标的乳穴；哺乳中的角色会被吸出乳汁
// ----------------------------------------------------------------------------
/datum/sex_action/suck_breast_hole
	name = "吸吮对方乳穴"
	check_same_tile = FALSE
	user_sex_part = SEX_PART_JAWS
	target_sex_part = SEX_PART_BREAST_HOLE

/datum/sex_action/suck_breast_hole/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 俯下身，把唇贴上 [target] 的乳穴，舌尖抵着穴口轻轻一舔。"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "suck")
	user.visible_message(span_warning(start_message))

/datum/sex_action/suck_breast_hole/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 含住 [target] 的乳穴轻轻吮吸，舌尖在穴口边缘一下一下地绕着圈。"
		if(SEX_FORCE_MID)
			message = "[user] 的舌头探进 [target] 的乳穴里搅动，吮吸的力道一点点加重，湿热的声响清楚可闻。"
		if(SEX_FORCE_HIGH)
			message = "[user] 用力嘬着 [target] 的乳穴，舌头又深又急地舔弄，连 [target] 的胸口都被吸得发红。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 几乎要把 [target] 的乳穴整个吃进嘴里，贪婪地舔吮吞咽，啧啧的水声一刻不停。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "suck")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.oralcourse_noise(user)

	user.sexcon.perform_sex_action(target, 1, 3, TRUE)
	target.sexcon.handle_passive_ejaculation()

	var/obj/item/organ/breasts/breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
	if(breasts)
		var/milk_to_add = min(max(breasts.breast_size, 1), breasts.milk_stored)
		if(breasts.lactating && milk_to_add > 0 && prob(25))
			user.reagents.add_reagent(/datum/reagent/consumable/milk, milk_to_add)
			breasts.milk_stored -= milk_to_add
			to_chat(user, span_notice("我尝到了一丝奶香。"))
			to_chat(target, span_notice("我感觉乳汁从乳穴里渗了出来。"))

/datum/sex_action/suck_breast_hole/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 恋恋不舍地松开 [target] 的乳穴，唇边还挂着湿亮的水痕。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "suck")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/suck_breast_hole/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE

// ----------------------------------------------------------------------------
// 强制插入：需要先以激进抓取控制目标
// ----------------------------------------------------------------------------
/datum/sex_action/force_breast_hole_sex
	name = "强迫插入对方乳穴"
	require_grab = TRUE
	stamina_cost = 1.0
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_COCK
	user_needs_functional = TRUE
	target_sex_part = SEX_PART_BREAST_HOLE

/datum/sex_action/force_breast_hole_sex/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/start_message = "[user] 一把扣住 [target]，不容抗拒地把阴茎硬顶进乳穴，粗暴地撑开了那处软肉！"
	if(breast_hole_is_lactating(target))
		start_message += " " + breast_hole_milk_start_line(target, "fuck")
	user.visible_message(span_warning(start_message))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/force_breast_hole_sex/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/message
	switch(user.sexcon.force)
		if(SEX_FORCE_LOW)
			message = "[user] 压着 [target]，阴茎在绷紧的乳穴里一下一下地磨，逼得 [target] 连呼吸都在发颤。"
		if(SEX_FORCE_MID)
			message = "[user] 强硬地掌控着节奏，把阴茎一下下顶进 [target] 的乳穴，逼出细碎的呜咽。"
		if(SEX_FORCE_HIGH)
			message = "[user] 不顾 [target] 的挣扎，在乳穴里又深又重地冲撞，撞得胸口不住发颤。"
		if(SEX_FORCE_EXTREME to SEX_FORCE_LUDICROUS)
			message = "[user] 像惩罚一样狠插 [target] 的乳穴，每一次都顶到最深处，逼得 [target] 连反抗都乱了。"
	if(breast_hole_is_lactating(target))
		message += " " + breast_hole_milk_perform_line(target, user, user.sexcon.force, "fuck")
	user.sexcon_action_message(user.sexcon.spanify_force(message))
	user.sexcon.intercourse_noise(target, TRUE)
	user.sexcon.do_thrust_animate(target)

	user.sexcon.perform_sex_action(user, 2, 4, TRUE)
	if(user.sexcon.check_active_ejaculation())
		var/ejac_message = "[user] 按住 [target]，把滚烫的精液尽数灌进 [target] 的乳穴！"
		if(breast_hole_is_lactating(target))
			ejac_message += " " + breast_hole_milk_ejac_line(target)
		user.visible_message(span_love(ejac_message))
		for(var/i = 1; i <= user.sexcon.get_load_bursts(); i++)
			user.sexcon.cum_into(splashed_user = target, orifice = SEX_PART_BREAST_HOLE, skip_knot_try = TRUE, consume_charge = i == 1 ? TRUE : FALSE)
			sleep(10)

	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || (user.STASTR > 12))
		if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			user.sexcon.try_pelvis_crush(target)

	user.sexcon.perform_sex_action(target, 0, 7, FALSE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/force_breast_hole_sex/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/finish_message = "[user] 抽身退开，乳穴被操得一时合不拢，白浊顺着胸口缓缓流下。"
	if(breast_hole_is_lactating(target))
		finish_message += " " + breast_hole_milk_finish_line(target, "fuck")
	user.visible_message(span_warning(finish_message))

/datum/sex_action/force_breast_hole_sex/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
