local add = language.Add;

add("weaponsets", "Наборы оружий");

-- Blood types
add("blood." .. DONT_BLEED, "Нет крови")
add("blood." .. BLOOD_COLOR_RED, "Нормальная красная кровь")
add("blood." .. BLOOD_COLOR_YELLOW, "Жёлтая кровь")
add("blood." .. BLOOD_COLOR_GREEN, "Зелёная кровь")
add("blood." .. BLOOD_COLOR_MECH, "Искры")
add("blood." .. BLOOD_COLOR_ANTLION, "Жёлтая кровь (муравьиных львов)")
add("blood." .. BLOOD_COLOR_ZOMBIE, "Кровь зомби")
add("blood." .. BLOOD_COLOR_ANTLION_WORKER, "Светло-зелёная кровь")

-- Options categories
add("weaponsets.category.weapons",  "Оружия")
add("weaponsets.category.player",   "Модель игрока")
add("weaponsets.category.movement", "Движение")
add("weaponsets.category.other",    "Другие параметры")

-- Weapons options
add("weaponsets.stripweapons.name",         "Отнимать оружия?")
add("weaponsets.stripweapons.description",  "Удаляет все оружия у игрока перед выдачей набора")
add("weaponsets.stripammo.name",            "Отнимать патроны?")
add("weaponsets.stripammo.description",     "Удаляет все патроны у игрока перед выдачей набора")
add("weaponsets.infiniteammo.name",         "Бесконечные патоны")
add("weaponsets.infiniteammo.description",  "Бескнечные посновные и второстепенные патроны у каждого оружия. Бесконечный магазин") -- TODO
add("weaponsets.givewithoutammo.name",      "Выдавать оружия без встроенных патронов")
add("weaponsets.givewithoutammo.description", "То есть выдавать полностью пустые оружия.") -- TODO
add("weaponsets.dropweapons.name",          "Ронять оружие при смерти?")
add("weaponsets.dropweapons.description",   "Будет ли при смерти выпадать из игрока оружие, которое он держал в руках перед смертью?")
add("weaponsets.defaultweapon.name",        "Начальное активное оружие")
add("weaponsets.defaultweapon.description", "То оружие, на которое переключится игрок сразу после выдачи набора") -- TODO

-- Player model options
add("weaponsets.model.name",                "Модель игрока (Playermodel)")
add("weaponsets.model.description",         "Model should be precached")
add("weaponsets.material.name",             "Материал модели")
add("weaponsets.material.description",      "Накладывает поверх всей модели определённый материал.")
add("weaponsets.color.name",                "Цвет модели с прозрачностью")
add("weaponsets.color.description",         "Цвет, в который будет окрашена вся модель.")
add("weaponsets.teamcolor.name",            "Цвет игрока (цвет команды)")
add("weaponsets.teamcolor.description",     "Цвет частей модели игрока, у каждой модели отличается. Не все модели поддерживают эту опцию.")
add("weaponsets.weaponcolor.name",          "Цвет оружия")
add("weaponsets.weaponcolor.description",   "Цвет оружия игрока (например цвет луча физ.пушки). Не все оружия поддерживают эту опцию.")
add("weaponsets.blood.name",                "Цвет крови игрока")
add("weaponsets.blood.description",         "")
add("weaponsets.scale.name",                "Масштаб модели [экспериментально]")
add("weaponsets.scale.description",         "Изменяет размер модели, взгляда, высоту шага, но не изменяет масштаб хитбоксов.")

-- Movement options
add("weaponsets.jump.name",             "Сила прыжка")
add("weaponsets.jump.description",      "Скорость, которая будет применена игроку при прижке")
add("weaponsets.stepsize.name",         "Высота прыжка")
add("weaponsets.stepsize.description",  "Максимальная высота, на которую игрок может шагнуть, не прыгая.")
add("weaponsets.gravity.name",          "Множитель гравитации [экспериментально]")
add("weaponsets.gravity.description",   "Глобальная гравитцая умножается на это число.") -- TODO
add("weaponsets.mass.name",             "Масса игрока [экспериментально]")
add("weaponsets.mass.description",      "")
add("weaponsets.friction.name",         "Трение [экспериментально]")
add("weaponsets.friction.description",  "Сколько трения игрок имеет при скольжении по поверхности.")
add("weaponsets.timescale.name",        "Скорость времени игрока")
add("weaponsets.timescale.description", "Позволяет замедля или ускорять все движения определённого игрока, поохоже на host_timescale")
add("weaponsets.enablewalk.name",       "Разрежить медленную ходьбу?")
add("weaponsets.enablewalk.description","Позволяет или запрещает медленно ходить +walk (по умолчанию клавиша Alt)")
add("weaponsets.normalspeed.name",      "Скорость ходьбы")
add("weaponsets.normalspeed.description","Скорость обычной ходьбы игрока WASD. Не бега, не медленной ходьбы (+walk), а обычной ходьбы.")
add("weaponsets.runspeed.name",         "Скорость бега")
add("weaponsets.runspeed.description",  "Скрость спринта игрока. +speed Чтобы запретитьигроку бегать, установите равным скорости ходьбы")
add("weaponsets.crouchspeed.name",      "Скорость передвижения сидя")
add("weaponsets.crouchspeed.description","Множитель скорости во время приседания. Не работает для значений больше 1.")
add("weaponsets.duckspeed.name",        "Скорость приседания (в секундах)")
add("weaponsets.duckspeed.description", "Как быстро игрок садится. Не работает для значений >= 1.")
add("weaponsets.unduckspeed.name",      "Скорость вставания (в секундах)")
add("weaponsets.unduckspeed.description","Как быстро игрок встаёт из присяда.")

-- Other options
add("weaponsets.removesuit.name",           "Отобрать костюм HEV?")
add("weaponsets.removesuit.description",
[[Cнарядить или нет игрока защитным костюмом H.E.V.
Костюм позволяет игроку напрягать моргало, медленно ходить, бегать, поднимать батарейки, использовать станции-аптечки и подзарядки, так же показывает интерфейс.
Ещё при смерти игрок издаёт противный писк.]])
add("weaponsets.allowflashlight.name",      "Резрешить фонарик?")
add("weaponsets.allowflashlight.description", "Позволяет игроку переключать свой фонарик.")
add("weaponsets.allowzoom.name",            "Разрешить приближать (zoom)?")
add("weaponsets.allowzoom.description",     "Может ли игрок приближать изображение. (бинд \"+zoom\")")
add("weaponsets.fov.name",                  "Поле зрения (FOV)")
add("weaponsets.fov.description",           "Поле зрение (ширина взгляда?) игрока в градусах. Установить в 0, чтобы использовать стандартное значение.")
add("weaponsets.godmode.name",              "Режим бога (бессмертие)")
add("weaponsets.godmode.description",       "Неуязвимость ко всем видам урона")
add("weaponsets.health.name",               "Количество здоровья")
add("weaponsets.health.description",        "Начальное количество здоровья")
add("weaponsets.maxhealth.name",            "Максимальное здоровье")
add("weaponsets.maxhealth.description",     "Максимальное значение до до которго можно восстановть здоровье.")
add("weaponsets.armor.name",                "Броня")
add("weaponsets.armor.description",         "Начальное количество брони (заряд костюма)")
