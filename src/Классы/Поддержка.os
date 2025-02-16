#Использовать logos
#Использовать csv
#Использовать "../internal"

#Область ОписаниеПеременных

Перем _лог; // Логирование: объект для вывода лога

Перем _ДанныеПоддержки; // Структура: Информация о поддержке
Перем _ИнформацияОПоддержке; // Массив из Структура: информация о файлах на поддержке
Перем _УровниФайлов; // Соответствие: Ключ - Строка - путь к файлу, Значение - число - его уровень

Перем _классы; // Массив из Строка: классы метаданных

Перем _КаталогИсходников; // Строка: Каталог исходников, получаемый на вход
Перем _ЭтоВыгрузкаКонфигуратора; // Булево: тип выгрузки. Истина, если это выгрузка из конфигуратора
Перем _ЭтоВыгрузкаЕДТ; // Булево: тип выгрузки. Истина, если это выгрузка из EDT

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриСозданииОбъекта(Знач пКаталогИсходников)
	
	_лог = Логирование.ПолучитьЛог(ИмяЛога());
	_КаталогИсходников = пКаталогИсходников;
	
	ОпределитьТипВыгрузки();
	
	_ИнформацияОПоддержке = ПрочитатьИнформациюОПоддержке();
	
	ЗаполнитьУровниФайлов();
	
КонецПроцедуры

#КонецОбласти

#Область ПрограммныйИнтерфейс

// Возвращает уровень поддержки
// Параметры:
//  пИмяФайла - Строка - относительный или абсолютный путь к файлу
// Возвращаемое значение:
//  Число - 0 - на замке
//          1 - на поддержке
//          2 - снято с поддержки
//          3 - нет поддержки
//          4 - не удалось определить уровень поддержки.
Функция Уровень(Знач пИмяФайла) Экспорт
	
	текУровень = _УровниФайлов[пИмяФайла];
	
	Если Не текУровень = Неопределено Тогда
		
		Возврат текУровень;
		
	КонецЕсли;
	
	файл = ВыгрузкаКонфигурации.АбсолютныйПуть(пИмяФайла);
	текУровень = _УровниФайлов[файл];
	
	Если текУровень = Неопределено Тогда
		
		текУровень = 4;
		_лог.Предупреждение("Не удалось определить уровень поддержки для %1", пИмяФайла);
		
	КонецЕсли;
	
	_УровниФайлов.Вставить(файл, текУровень);
	
	Возврат текУровень;
	
КонецФункции

// Все файлы с заданным уровнем поддержки
//
// Параметры:
//  пУровень - Число - уровень поддержки
//  пМодификатор - Строка - "+", "-", "=". 2- - вернет все файлы с уровнями 0, 1 и 2, 3= - все файлы с уровнем 3.
//
// Возвращаемое значение:
//  Массив - массив с путями к файлам.
Функция ВсеФайлы(Знач пУровень, Знач пМодификатор = "=") Экспорт
	
	массивФайлов = Новый Массив;
	
	Для каждого цЭлемент Из _ИнформацияОПоддержке Цикл
		
		Если УровеньСоответствуетУсловию(цЭлемент.Support, пУровень, пМодификатор) Тогда
			
			массивФайлов.Добавить(цЭлемент.file);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат массивФайлов;
	
КонецФункции

Функция Данные() Экспорт
	
	Возврат _ДанныеПоддержки;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ИмяЛога() Экспорт
	
	Возврат "oscript.app.parseSupport";
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОпределитьТипВыгрузки()
	
	_ЭтоВыгрузкаКонфигуратора = ВыгрузкаКонфигурации.ЭтоВыгрузкаКонфигурации(_КаталогИсходников);
	_ЭтоВыгрузкаЕДТ = ВыгрузкаКонфигурации.ЭтоВыгрузкаЕДТ(_КаталогИсходников);
	
	_лог.Отладка("Это выгрузка конфигурации: " + _ЭтоВыгрузкаКонфигуратора);
	_лог.Отладка("Это выгрузка EDT: " + _ЭтоВыгрузкаЕДТ);
	
	Если _ЭтоВыгрузкаЕДТ = _ЭтоВыгрузкаКонфигуратора Тогда
		
		ВызватьИсключение "Не удалось определить тип выгрузки";
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьУровниФайлов()
	
	_УровниФайлов = Новый Соответствие;
	
	Для каждого цЭлемент Из _ИнформацияОПоддержке Цикл
		
		текУровень = цЭлемент.Support;
		
		_УровниФайлов.Вставить(цЭлемент.file, текУровень);
		
	КонецЦикла;
	
КонецПроцедуры

Функция УровеньСоответствуетУсловию(УровеньФайла, ТребуемыйУровень, Модификатор)
	
	Возврат (Модификатор = "="
			И УровеньФайла = ТребуемыйУровень)
		ИЛИ (Модификатор = "+"
			И УровеньФайла >= ТребуемыйУровень)
		ИЛИ (Модификатор = "-"
			И УровеньФайла <= ТребуемыйУровень);
	
КонецФункции

#Область ЧтениеИнформацииОПоддержке

Функция ПрочитатьИнформациюОПоддержке()
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		путьКФайлуПоддержки = ОбъединитьПути(_КаталогИсходников, "Ext", "ParentConfigurations.bin");
		
	ИначеЕсли _ЭтоВыгрузкаЕДТ Тогда
		
		путьКФайлуПоддержки = ОбъединитьПути(_КаталогИсходников, "Configuration", "ParentConfigurations.bin");
		
	Иначе
		
		ВызватьИсключение "Не удалось определить тип выгрузки";
		
	КонецЕсли;
	
	Если ВыгрузкаКонфигурации.ФайлСуществует(путьКФайлуПоддержки) Тогда
		
		_лог.Отладка(СтрШаблон("Файл поддержки <%1> найден", путьКФайлуПоддержки));
		
	Иначе
		
		_лог.Ошибка(СтрШаблон("Файл поддержки <%1> НЕ найден", путьКФайлуПоддержки));
		
		Возврат Новый Массив;
		
	КонецЕсли;
	
	ЗаполнитьДанныеПоддержки(путьКФайлуПоддержки);
	
	описанияПоддержки = _ДанныеПоддержки["ОписанияОбъектов"];
	описанияФайлов = Новый Массив;
	
	_классы = Классы();
	
	Для каждого цФайлМодуля Из НайтиФайлы(_КаталогИсходников, "*.bsl", Истина) Цикл
		
		структФайла = Новый Структура;
		структФайла.Вставить("file", цФайлМодуля.ПолноеИмя);
		структФайла.Вставить("uuid", ПолучитьУУИДПоФайлу(цФайлМодуля.ПолноеИмя));
		
		уровеньПоддержки = 4;
		
		Для каждого цЭлементПоддержки Из ОбеспечитьЭлемент(описанияПоддержки, структФайла.uuid, Новый Массив) Цикл
			
			уровеньПоддержки = Мин(уровеньПоддержки, Число(цЭлементПоддержки));
			
		КонецЦикла;
		
		структФайла.Вставить("Support", уровеньПоддержки);
		
		описанияФайлов.Добавить(структФайла);
		
	КонецЦикла;
	
	Возврат описанияФайлов;
	
КонецФункции

Процедура ЗаполнитьДанныеПоддержки(Знач пПутьКФайлуПоддержки)
	
	чтениеТекста = Новый ЧтениеТекста(пПутьКФайлуПоддержки, "UTF-8");
	текстПоддержки = чтениеТекста.Прочитать();
	чтениеТекста.Закрыть();
	
	данные = ЧтениеCSV.ИзСтроки(текстПоддержки, ",");
	
	всегоКонфигураций = Число(данные[Индекс_КоличествоКонфигурацийПоддержки()]);
	
	_лог.Отладка("Количество конфигураций поставщика: " + всегоКонфигураций);
	
	сдвиг = 3;
	
	_ДанныеПоддержки = Новый Соответствие;
	
	соотОбъекты = Новый Соответствие;
	
	ид_ЗапрещеныИзмененияКонфигурации = 1;
	ид_УУИД_Конфигурации = 2;
	ид_ВерсияКонфигурации = 3;
	ид_ПоставщикКонфигурации = 4;
	ид_Конфигурация = 5;
	ид_ВсегоОбъектовВКонфигурации = 6;
	
	ид_НачалоБлокаОбъектов = 7;
	полейДляОбъекта = 4;
	
	ид_УровеньОбъекта = 0;
	ид_ПоставкаОбъекта = 1;
	ид_УУИД_Объекта = 2;
	ид_УУИД_Поставщика = 3;
	
	служебныхПолейПослеДанныхОбъектов = 9;
	
	Для цНомерКонфигурации = 1 По всегоКонфигураций Цикл
		
		поставка = Новый Структура;
		
		ЗапрещеныИзменения = данные[сдвиг + ид_ЗапрещеныИзмененияКонфигурации];
		
		Если ЗапрещеныИзменения = "0" Тогда
			
			РазрешеныИзменения = Истина;
			
		ИначеЕсли ЗапрещеныИзменения = "1" Тогда
			
			РазрешеныИзменения = Ложь;
			
		Иначе
			
			ВызватьИсключение "Неизвестный вариант настройки изменений конфигурации, ожидалось 0 или 1, а получили " + ЗапрещеныИзменения;
			
		КонецЕсли;
		
		поставка.Вставить("РазрешеныИзменения", РазрешеныИзменения);
		поставка.Вставить("УУИД", данные[сдвиг + ид_УУИД_Конфигурации]); // гуид конфигурации ?
		
		версия = данные[сдвиг + ид_ВерсияКонфигурации];
		версия = УбратьОборачиваниеВКавычки(версия);
		
		поставщик = данные[сдвиг + ид_ПоставщикКонфигурации];
		поставщик = УбратьОборачиваниеВКавычки(поставщик);
		
		конфигурация = данные[сдвиг + ид_Конфигурация];
		конфигурация = УбратьОборачиваниеВКавычки(конфигурация);
		
		поставка.Вставить("Версия", версия);
		поставка.Вставить("Поставщик", поставщик);
		поставка.Вставить("Конфигурация", конфигурация);
		
		всегоОбъектов = Число(данные[сдвиг + ид_ВсегоОбъектовВКонфигурации]);
		
		_лог.Отладка("Чтение конфигурации: " + поставка.Конфигурация
			+ ", версии: " + поставка.Версия
			+ ", разрешены изменения " + РазрешеныИзменения);
		
		_лог.Отладка("Объектов: " + всегоОбъектов);
		
		массивОбъектов = Новый Массив;
		
		началоБлокаОбъектов = сдвиг + ид_НачалоБлокаОбъектов;
		
		Для цНомерОбъекта = 0 По всегоОбъектов - 1 Цикл
			
			сдвигОбъекта = началоБлокаОбъектов + цНомерОбъекта * полейДляОбъекта;
			
			описаниеОбъекта = Новый Структура;
			
			УровеньПоддержки = данные[сдвигОбъекта + ид_УровеньОбъекта]; // 0 - не редактируется, 1 - с сохранением поддержки, 2 - снято
			
			Если Не РазрешеныИзменения Тогда
				
				УровеньПоддержки = 0;
				
			КонецЕсли;
			
			описаниеОбъекта.Вставить("Поддержка", УровеньПоддержки);
			
			// 0 - изменения разрешены, 1 - изменения не рекомендуются, 2 - изменения запрещены, -1 - включение в конфигурацию не рекомендуется
			описаниеОбъекта.Вставить("Поставка", данные[сдвигОбъекта + ид_ПоставкаОбъекта]);
			описаниеОбъекта.Вставить("УУИД", данные[сдвигОбъекта + ид_УУИД_Объекта]);
			описаниеОбъекта.Вставить("УУИДПоставщика", данные[сдвигОбъекта + ид_УУИД_Поставщика]);
			
			массивОбъектов.Добавить(описаниеОбъекта);
			
			ОбеспечитьЭлемент(соотОбъекты, описаниеОбъекта.УУИД, Новый Массив).Добавить(описаниеОбъекта.Поддержка);
			
		КонецЦикла;
		
		поставка.Вставить("Объекты", массивОбъектов);
		
		_ДанныеПоддержки.Вставить(поставка.Конфигурация, поставка);
		
		сдвиг = сдвиг + служебныхПолейПослеДанныхОбъектов + всегоОбъектов * полейДляОбъекта;
		
	КонецЦикла;
	
	_ДанныеПоддержки.Вставить("ОписанияОбъектов", соотОбъекты);
	
КонецПроцедуры

Функция Индекс_КоличествоКонфигурацийПоддержки()
	
	Возврат 2;
	
КонецФункции

Функция ОбеспечитьЭлемент(пСоответствие, пКлюч, пЗначениеПоУмолчанию)
	
	значение = пСоответствие[пКлюч];
	
	Если Не значение = Неопределено Тогда
		
		Возврат значение;
		
	Иначе
		
		пСоответствие.Вставить(пКлюч, пЗначениеПоУмолчанию);
		
		Возврат пЗначениеПоУмолчанию;
		
	КонецЕсли;
	
КонецФункции

Функция УбратьОборачиваниеВКавычки(Знач ИсходнаяСтрока)
	
	безОборачивания = СтрЗаменить(ИсходнаяСтрока, """""", """");
	
	Если СтрНачинаетсяС(безОборачивания, """") Тогда
		
		безОборачивания = Сред(безОборачивания, 2);
		
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа(безОборачивания, """") Тогда
		
		безОборачивания = Лев(безОборачивания, СтрДлина(безОборачивания) - 1);
		
	КонецЕсли;
	
	Возврат безОборачивания;
	
КонецФункции

#Область ПолучениеУУИДПоФайлу

Функция ПолучитьУУИДПоФайлу(Знач пПутьКФайлу)
	
	файлМодуля = Новый Файл(пПутьКФайлу);
	путь = СтрЗаменить(файлМодуля.ПолноеИмя, "/", "\");
	компонентыПути = СтрРазделить(путь, "\");
	
	Если ЭтоКорень(компонентыПути) Тогда
		
		данныеОписания = ДанныеОписания_Корень(компонентыПути);
		
	ИначеЕсли ЭтоФорма(компонентыПути) Тогда
		
		данныеОписания = ДанныеОписания_Форма(компонентыПути);
		
	ИначеЕсли ЭтоКоманда(компонентыПути) Тогда
		
		данныеОписания = ДанныеОписания_Команда(компонентыПути);
		
	ИначеЕсли ЭтоОбъект(компонентыПути) Тогда
		
		данныеОписания = ДанныеОписания_Объект(компонентыПути);
		
	Иначе
		
		данныеОписания = ДанныеОписания();
		_лог.Предупреждение(СтрШаблон("Не удалось получить xml файл для <%1>.", пПутьКФайлу));
		
	КонецЕсли;
	
	ууид = УУИДИзФайлаОписания(пПутьКФайлу, данныеОписания);
	
	Если ууид = Неопределено Тогда
		
		_лог.Предупреждение("Не удалось получить uuid из " + данныеОписания.Путь);
		
	КонецЕсли;
	
	Возврат ууид;
	
КонецФункции

Функция УУИДИзФайлаОписания(Знач пПутьКФайлу, Знач ДанныеОписания)
	
	файлОписания = Новый Файл(ДанныеОписания.Путь);
	
	Если Не файлОписания.Существует()
		ИЛИ Не файлОписания.ЭтоФайл() Тогда
		
		_лог.Предупреждение(СтрШаблон("Не удалось найти xml файл для <%1>. Искали в <%2>", пПутьКФайлу, ДанныеОписания.Путь));
		
		Возврат Неопределено;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ДанныеОписания.Имя) Тогда
		
		ууид = УУИДИзЗаголовкаФайлаОписания(ДанныеОписания);
		
	Иначе
		
		ууид = УУИДИзТелаФайлаОписания(ДанныеОписания);
		
	КонецЕсли;
	
	Возврат ууид;
	
КонецФункции

Функция УУИДИзТелаФайлаОписания(Знач ДанныеОписания)
	
	ууид = Неопределено;
	
	чтениеXML = Новый ЧтениеXML;
	
	чтениеXML.ОткрытьФайл(ДанныеОписания.Путь);
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента
			И ВРег(ЧтениеXML.Имя) = ДанныеОписания.Тип Тогда
			
			ууид = ЧтениеXML.ПолучитьАтрибут("uuid");
			
		КонецЕсли;
		
		Если Не ууид = Неопределено
			И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента
			И ВРег(ЧтениеXML.Имя) = ВРег("Name") Тогда
			
			ЧтениеXML.Прочитать();
			
			Если ВРег(ЧтениеXML.Значение) = ВРег(ДанныеОписания.Имя) Тогда
				
				// Нашли описание нужной команды
				Прервать;
				
			Иначе
				
				ууид = Неопределено;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат ууид;
	
КонецФункции

Функция УУИДИзЗаголовкаФайлаОписания(Знач ДанныеОписания)
	
	ууид = Неопределено;
	
	чтениеXML = Новый ЧтениеXML;
	
	чтениеXML.ОткрытьФайл(ДанныеОписания.Путь);
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента
			И Не _классы.Найти(ВРег(ЧтениеXML.Имя)) = Неопределено Тогда
			
			ууид = ЧтениеXML.ПолучитьАтрибут("uuid");
			Прервать;
			
		КонецЕсли;
		
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат ууид;
	
КонецФункции

#Область ДанныеОписания

Функция ДанныеОписания()
	
	данныеОписания = Новый Структура;
	
	данныеОписания.Вставить("Путь", "");
	данныеОписания.Вставить("Имя", "");
	данныеОписания.Вставить("Тип", "");
	
	Возврат данныеОписания;
	
КонецФункции

Функция ЭтоКорень(Знач пКомпоненты)
	
	имяФайла = ВРег(КомпонентСКонца(пКомпоненты, 1));
	
	Возврат имяФайла = Врег("ExternalConnectionModule.bsl")
		ИЛИ имяФайла = Врег("ManagedApplicationModule.bsl")
		ИЛИ имяФайла = Врег("OrdinaryApplicationModule.bsl")
		ИЛИ имяФайла = Врег("SessionModule.bsl");
	
КонецФункции

Функция ДанныеОписания_Корень(Знач компонентыПути)
	
	данныеОписания = ДанныеОписания();
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 2, ПолучитьРазделительПути() + "Configuration.xml");
		
	Иначе
		
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути,
				2,
				ПолучитьРазделительПути() + ОбъединитьПути("Configuration", "Configuration.mdo"));
		
	КонецЕсли;
	
	Возврат данныеОписания;
	
КонецФункции

Функция ЭтоФорма(Знач пКомпоненты)
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		// \Ext\Form\
		
		Возврат ВРег(КомпонентСКонца(пКомпоненты, 2)) = ВРег("Form")
			И ВРег(КомпонентСКонца(пКомпоненты, 3)) = ВРег("Ext");
		
	Иначе
		
		// Проверяем, что рядом лежит файл формы
		
		путьКФорме = ПутьКФайлуОписания(пКомпоненты, 1, "/Form.form");
		
		Возврат ВыгрузкаКонфигурации.ФайлСуществует(путьКФорме);
		
	КонецЕсли;
	
КонецФункции

Функция ДанныеОписания_Форма(Знач компонентыПути)
	
	данныеОписания = ДанныеОписания();
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 3);
		
	Иначе
		
		Если ВРег(КомпонентСКонца(компонентыПути, 3)) = "COMMONFORMS" Тогда
			
			имяОбъекта = КомпонентСКонца(компонентыПути, 2);
			данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 1, ПолучитьРазделительПути() + имяОбъекта + ".mdo");
			
		Иначе
			
			имяОбъекта = КомпонентСКонца(компонентыПути, 4);
			данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 3, ПолучитьРазделительПути() + имяОбъекта + ".mdo");
			данныеОписания.Имя = КомпонентСКонца(компонентыПути, 2);
			данныеОписания.Тип = ВРег("Forms");
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат данныеОписания;
	
КонецФункции

Функция ЭтоКоманда(Знач пКомпоненты)
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		// имяОбъекта\Commands\имяКоманды\Ext\CommandModule.bsl
		
		имяФайла = КомпонентСКонца(пКомпоненты, 1);
		
		Возврат ВРег(имяФайла) = Врег("CommandModule.bsl")
			И ВРег(КомпонентСКонца(пКомпоненты, 2)) = ВРег("Ext")
			И ВРег(КомпонентСКонца(пКомпоненты, 4)) = ВРег("Commands");
		
	Иначе
		
		// имяОбъекта\Commands\имяКоманды\CommandModule.bsl
		
		имяФайла = КомпонентСКонца(пКомпоненты, 1);
		
		Возврат ВРег(имяФайла) = Врег("CommandModule.bsl")
			И ВРег(КомпонентСКонца(пКомпоненты, 3)) = ВРег("Commands");
		
	КонецЕсли;
	
КонецФункции

Функция ДанныеОписания_Команда(Знач компонентыПути)
	
	данныеОписания = ДанныеОписания();
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 4);
		данныеОписания.Имя = КомпонентСКонца(компонентыПути, 3);
		данныеОписания.Тип = ВРег("Command");
		
	Иначе
		
		имяОбъекта = КомпонентСКонца(компонентыПути, 4);
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 3, ПолучитьРазделительПути() + имяОбъекта + ".mdo");
		данныеОписания.Имя = КомпонентСКонца(компонентыПути, 2);
		данныеОписания.Тип = ВРег("Commands");
		
	КонецЕсли;
	
	Возврат данныеОписания;
	
КонецФункции

Функция ЭтоОбъект(Знач пКомпоненты)
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		// \Ext\
		
		Возврат ВРег(КомпонентСКонца(пКомпоненты, 2)) = ВРег("Ext");
		
	Иначе
		
		// Считаем все объекты модулями, если они не были перехвачены раньше. Другой способ пока не придуман.
		Возврат Истина;
		
	КонецЕсли;
	
КонецФункции

Функция ДанныеОписания_Объект(Знач компонентыПути)
	
	данныеОписания = ДанныеОписания();
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 2);
		
	Иначе
		
		имяОбъекта = КомпонентСКонца(компонентыПути, 2);
		данныеОписания.Путь = ПутьКФайлуОписания(компонентыПути, 1, ПолучитьРазделительПути() + имяОбъекта + ".mdo");
		
	КонецЕсли;
	
	Возврат данныеОписания;
	
КонецФункции

Функция КомпонентСКонца(Знач пКомпоненты, Знач пНомерСКонца, Знач пЗначениеПоУмолчанию = "")
	
	элементов = пКомпоненты.Количество();
	
	Если пНомерСКонца > элементов Тогда
		
		Возврат пЗначениеПоУмолчанию;
		
	КонецЕсли;
	
	Возврат пКомпоненты[элементов - пНомерСКонца];
	
КонецФункции

Функция ПутьКФайлуОписания(Знач пКомпоненты, Знач пУдалитьУровней, Знач пИмяФайла = ".xml")
	
	компонентыПути = Новый Массив;
	
	Для ц = 0 По пКомпоненты.ВГраница() - пУдалитьУровней Цикл
		
		компонентыПути.Добавить(пКомпоненты[ц]);
		
	КонецЦикла;
	
	Возврат СтрСоединить(компонентыПути, ПолучитьРазделительПути()) + пИмяФайла;
	
КонецФункции

#КонецОбласти

#КонецОбласти

Функция Классы()
	
	классы = Новый Массив;
	
	классы.Добавить("AccountingRegister");
	классы.Добавить("AccumulationRegister");
	классы.Добавить("BusinessProcess");
	классы.Добавить("CalculationRegister");
	классы.Добавить("Catalog");
	классы.Добавить("ChartOfAccounts");
	классы.Добавить("ChartOfCalculationTypes");
	классы.Добавить("ChartOfCharacteristicTypes");
	классы.Добавить("CommandGroup");
	классы.Добавить("CommonAttribute");
	классы.Добавить("CommonCommand");
	классы.Добавить("CommonForm");
	классы.Добавить("CommonModule");
	классы.Добавить("CommonPicture");
	классы.Добавить("CommonTemplate");
	классы.Добавить("Configuration");
	классы.Добавить("Constant");
	классы.Добавить("DataProcessor");
	классы.Добавить("DefinedType");
	классы.Добавить("Document");
	классы.Добавить("DocumentJournal");
	классы.Добавить("DocumentNumerator");
	классы.Добавить("Enum");
	классы.Добавить("EventSubscription");
	классы.Добавить("ExchangePlan");
	классы.Добавить("ExternalDataSource");
	классы.Добавить("FilterCriterion");
	классы.Добавить("Form");
	классы.Добавить("FunctionalOption");
	классы.Добавить("FunctionalOptionsParameter");
	классы.Добавить("HTTPService");
	классы.Добавить("InformationRegister");
	классы.Добавить("Language");
	классы.Добавить("Report");
	классы.Добавить("Role");
	классы.Добавить("ScheduledJob");
	классы.Добавить("Sequence");
	классы.Добавить("SessionParameter");
	классы.Добавить("SettingsStorage");
	классы.Добавить("Style");
	классы.Добавить("StyleItem");
	классы.Добавить("Task");
	классы.Добавить("WebService");
	классы.Добавить("WSReference");
	классы.Добавить("XDTOPackage");
	
	классыВРег = Новый Массив;
	
	Если _ЭтоВыгрузкаКонфигуратора Тогда
		
		префикс = "";
		
	Иначе
		
		префикс = "mdclass:";
		
	КонецЕсли;
	
	Для каждого цЭлемент Из классы Цикл
		
		классыВРег.Добавить(ВРег(префикс + цЭлемент));
		
	КонецЦикла;
	
	Возврат классыВРег;
	
КонецФункции

#КонецОбласти

#КонецОбласти