local add = language.Add;

add("weaponsets", "Наборы оружий");

-- Blood types
add("blood." .. DONT_BLEED,             "Нет крови")
add("blood." .. BLOOD_COLOR_RED,        "Нормальная красная кровь")
add("blood." .. BLOOD_COLOR_YELLOW,     "Жёлтая кровь")
add("blood." .. BLOOD_COLOR_GREEN,      "Зелёная кровь")
add("blood." .. BLOOD_COLOR_MECH,       "Искры")
add("blood." .. BLOOD_COLOR_ANTLION,    "Жёлтая кровь (муравьиных львов)")
add("blood." .. BLOOD_COLOR_ZOMBIE,     "Кровь зомби")
add("blood." .. BLOOD_COLOR_ANTLION_WORKER, "Светло-зелёная кровь")

-- Infinite ammo enum
add("infiniteammo.0", "Выключить")
add("infiniteammo.1", "Основные")
add("infiniteammo.2", "Второстепенные")
add("infiniteammo.3", "Все")

-- Default sets
add("weaponsets.set.clear",     "Без оружия")
add("weaponsets.set.sandbox",   "Набор песочницы")
add("weaponsets.set.build",     "Строительство")
add("weaponsets.set.default",   "Стандартный из Garry's mod")
add("weaponsets.set.inherit",   "Унаследовать глобальный")

-- Options categories
add("weaponsets.category.weapons",  "Оружия")
add("weaponsets.category.player",   "Модель игрока")
add("weaponsets.category.movement", "Движение")
add("weaponsets.category.other",    "Другие параметры")

-- Weapons options
add("weaponsets.stripweapons",          "Отнимать оружия?")
add("weaponsets.stripweapons.desc",     "Удаляет все оружия у игрока перед выдачей набора")
add("weaponsets.stripammo",             "Отнимать патроны?")
add("weaponsets.stripammo.desc",        "Удаляет все патроны у игрока перед выдачей набора")
add("weaponsets.infiniteammo",          "Бесконечные патоны")
add("weaponsets.infiniteammo.desc",     "Бесконечные основные и/или второстепенные патроны у каждого оружия. Устанавливает патроны в 99 каждые 5 секунд")
add("weaponsets.givewithoutammo",       "Выдавать оружия без встроенных патронов")
add("weaponsets.givewithoutammo.desc",  "То есть выдавать полностью пустые оружия без патронов в магазине")
add("weaponsets.dropweapons",           "Ронять оружие при смерти?")
add("weaponsets.dropweapons.desc",      "Будет ли при смерти выпадать из игрока оружие, которое он держал в руках перед смертью?")
add("weaponsets.defaultweapon",         "Начальное активное оружие")
add("weaponsets.defaultweapon.desc",    "То оружие, на которое переключится игрок сразу после выдачи набора")

-- Player model options
add("weaponsets.model",                 "Модель игрока (Playermodel)")
add("weaponsets.model.desc",            "Model should be precached")
add("weaponsets.material",              "Материал модели")
add("weaponsets.material.desc",         "Накладывает поверх всей модели определённый материал.")
add("weaponsets.color",                 "Цвет модели с прозрачностью")
add("weaponsets.color.desc",            "Цвет, в который будет окрашена вся модель.")
add("weaponsets.teamcolor",             "Цвет игрока (цвет команды)")
add("weaponsets.teamcolor.desc",        "Цвет частей модели игрока, у каждой модели отличается. Не все модели поддерживают эту опцию.")
add("weaponsets.weaponcolor",           "Цвет оружия")
add("weaponsets.weaponcolor.desc",      "Цвет оружия игрока (например цвет луча физ.пушки). Не все оружия поддерживают эту опцию.")
add("weaponsets.blood",                 "Цвет крови игрока")
add("weaponsets.blood.desc",            "")
add("weaponsets.scale",                 "Масштаб модели [экспериментально]")
add("weaponsets.scale.desc",            "Изменяет размер модели, взгляда, высоту шага, но не изменяет масштаб хитбоксов.")

-- Movement options
add("weaponsets.jump",              "Сила прыжка")
add("weaponsets.jump.desc",         "Скорость, которая будет применена игроку при прижке")
add("weaponsets.stepsize",          "Высота прыжка")
add("weaponsets.stepsize.desc",     "Максимальная высота, на которую игрок может шагнуть, не прыгая.")
add("weaponsets.gravity",           "Множитель гравитации [экспериментально]")
add("weaponsets.gravity.desc",      "Глобальная гравитация умножается на это число.") -- TODO
add("weaponsets.mass",              "Масса игрока [экспериментально]")
add("weaponsets.mass.desc",         "")
add("weaponsets.friction",          "Трение [экспериментально]")
add("weaponsets.friction.desc",     "Сколько трения игрок имеет при скольжении по поверхности.")
add("weaponsets.timescale",         "Скорость времени игрока")
add("weaponsets.timescale.desc",    "Позволяет замедля или ускорять все движения определённого игрока, поохоже на host_timescale")
add("weaponsets.enablewalk",        "Разрежить медленную ходьбу?")
add("weaponsets.enablewalk.desc",   "Позволяет или запрещает медленно ходить +walk (по умолчанию клавиша Alt)")
add("weaponsets.normalspeed",       "Скорость ходьбы")
add("weaponsets.normalspeed.desc",  "Скорость обычной ходьбы игрока WASD. Не бега, не медленной ходьбы (+walk), а обычной ходьбы.")
add("weaponsets.runspeed",          "Скорость бега")
add("weaponsets.runspeed.desc",     "Скрость спринта игрока. +speed Чтобы запретитьигроку бегать, установите равным скорости ходьбы")
add("weaponsets.crouchspeed",       "Скорость передвижения сидя")
add("weaponsets.crouchspeed.desc",  "Множитель скорости во время приседания. Не работает для значений больше 1.")
add("weaponsets.duckspeed",         "Скорость приседания (в секундах)")
add("weaponsets.duckspeed.desc",    "Как быстро игрок садится. Не работает для значений >= 1.")
add("weaponsets.unduckspeed",       "Скорость вставания (в секундах)")
add("weaponsets.unduckspeed.desc",  "Как быстро игрок встаёт из присяда.")

-- Other options
add("weaponsets.removesuit",            "Отобрать костюм HEV?")
add("weaponsets.removesuit.desc",
[[Cнарядить или нет игрока защитным костюмом H.E.V.
Костюм позволяет игроку напрягать моргало, медленно ходить, бегать, поднимать батарейки, использовать станции-аптечки и подзарядки, так же показывает интерфейс.
Ещё при смерти игрок издаёт противный писк.]])
add("weaponsets.allowflashlight",       "Резрешить фонарик?")
add("weaponsets.allowflashlight.desc",  "Позволяет игроку переключать свой фонарик.")
add("weaponsets.allowzoom",             "Разрешить приближать (zoom)?")
add("weaponsets.allowzoom.desc",        "Может ли игрок приближать изображение. (бинд \"+zoom\")")
add("weaponsets.fov",                   "Поле зрения (FOV)")
add("weaponsets.fov.desc",              "Поле зрение (ширина взгляда?) игрока в градусах. Установить в 0, чтобы использовать стандартное значение.")
add("weaponsets.godmode",               "Режим бога (бессмертие)")
add("weaponsets.godmode.desc",          "Неуязвимость ко всем видам урона")
add("weaponsets.health",                "Количество здоровья")
add("weaponsets.health.desc",           "Начальное количество здоровья")
add("weaponsets.maxhealth",             "Максимальное здоровье")
add("weaponsets.maxhealth.desc",        "Максимальное значение до до которго можно восстановть здоровье.")
add("weaponsets.armor",                 "Броня")
add("weaponsets.armor.desc",            "Начальное количество брони (заряд костюма)")
