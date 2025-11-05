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
			"Кто на связи? (нажми F)",
			DialogEmotion.Surprised
		),
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
			"Сейчас это не важно!",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"Небольшое обучение, как им пользоваться",
			DialogEmotion.Sad
		),

		DialogMsg.new(
			"Q - шаг назад",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"CTRL + R - перемотка",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"CTRL + SHIFT + R - быстрая перемотка",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"И, основная функция - ",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"E - Сменить проявление мира",
			DialogEmotion.Sad
		),
		DialogMsg.new(
			"Двигайся дальше пока я буду думать как тебя вытащить",
			DialogEmotion.Beg
		)
	],
	"keep_moving": [
		DialogMsg.new(
			"Я вижу у тебя хорошо получается",
			DialogEmotion.Surprised
		),
		DialogMsg.new(
			"Продолжай двигаться дальше, я почти настроил приемник",
			DialogEmotion.Beg
		)
	],
	"already_here": [
		DialogMsg.new(
			"Рядом есть место, в котором связь с мирами",
			DialogEmotion.Confused
		),
		DialogMsg.new(
			"Достаточно стабильна. Ты почти у цели!",
			DialogEmotion.Point
		),
		DialogMsg.new(
			"Не сдавайся! Осталось совсем немного",
			DialogEmotion.Beg
		)
	]
}