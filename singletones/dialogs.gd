extends Node

enum DialogEmotion {
	Neutral,
	Surprised,
	Sad,
	Confused,
	Beg,
	Point
}

class DialogMsg:
	var text : String
	var emotion : DialogEmotion
	
	func _init(t : String, e : DialogEmotion):
		self.text = t
		self.emotion = e


var dialogs = {
	"clock": [
		DialogMsg.new(
			"Давно я не получал сигналы от этого устройства",
			DialogEmotion.Confused
		),
		DialogMsg.new(
			"О! Это ты, котик",
			DialogEmotion.Surprised
		),
		DialogMsg.new(
			"Я не знал, куда ты пропал и очень волновался",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"Это же экспериментальное устройство,",
			DialogEmotion.Surprised
		),
		DialogMsg.new(
			"которое я использовал для перемещения между параллельными мирами",
			DialogEmotion.Surprised
		),
		DialogMsg.new(
			"Но в результате парадокса миры связались воедино и",
			DialogEmotion.Point
		),
		DialogMsg.new(
			"Стали зависимы друг от друга",
			DialogEmotion.Confused
		),
		DialogMsg.new(
			"А оно потерялось где-то между",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"Как хорошо что ты его нашел!",
			DialogEmotion.Point
		),
		DialogMsg.new(
			"Но это значит что ты как-то смог активировать машину?",
			DialogEmotion.Confused
		),
		DialogMsg.new(
			"Двигайся дальше пока я буду думать как тебя вытащить",
			DialogEmotion.Beg
		)
	]
}

# DialogMsg.new(
# 			"Просто невероятно! там небезопасно, надо поскорее вытащить тебя оттуда",
# 			DialogEmotion.Beg
# 		),
# 		DialogMsg.new(
# 			"Тут плохая связь и я не могу вытащить тебя, но, судя по моим наблюдениям",
# 			DialogEmotion.Neutral
# 		),
# 		DialogMsg.new(
# 			"Если ты пойдешь дальше, то прибудешь в подходящее место",
# 			DialogEmotion.Neutral
# 		),
# 		DialogMsg.new(
# 			"И я смогу вытащить тебя",
# 			DialogEmotion.Neutral
# 		)