//©///////////////////////////////////////////////////////////////////////////©//
//
//  Copyright 2021-2023 BIA-Technologies Limited Liability Company
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//©///////////////////////////////////////////////////////////////////////////©//

/////////////////////////////////////////////////////////////////////////////////
// Экспортные процедуры и функции, предназначенные для использования другими 
// объектами конфигурации или другими программами
///////////////////////////////////////////////////////////////////////////////// 
#Область ПрограммныйИнтерфейс

// ИнициализироватьКонтекст
//  Выполняет начальную настройку для работы с хранимым контекстом
Процедура ИнициализироватьКонтекст() Экспорт
	
#Если Клиент Тогда
	ЮТКонтекстКлиент.ИнициализироватьКонтекст();
#КонецЕсли
	ЮТКонтекстСервер.ИнициализироватьКонтекст();
	
КонецПроцедуры

// ДанныеКонтекста
//  Возвращает хранимые данные контекста.
//  Существует отдельно контекст сервера, отдельно клиента, эти контексты никак не связаны и никак не синхронизируются
// Возвращаемое значение:
//  Структура - Данные контекста
Функция ДанныеКонтекста() Экспорт
	
#Если Клиент Тогда
	Возврат ЮТКонтекстКлиент.ДанныеКонтекста();
#Иначе
	Возврат ЮТКонтекстСервер.ДанныеКонтекста();
#КонецЕсли
	
КонецФункции

// ЗначениеКонтекста
//  Возвращает значение вложенного контекста, вложенного реквизита контекста
// Параметры:
//  ИмяРеквизита - Строка - Имя реквизита/вложенного контекста
// 
// Возвращаемое значение:
//  Структура, Неопределено - Значение реквизита/вложенного контекста
Функция ЗначениеКонтекста(ИмяРеквизита, ПолучитьССервера = Ложь) Экспорт
	
#Если Клиент Тогда
	Если ПолучитьССервера Тогда
		Возврат ЮТКонтекстСервер.ЗначениеКонтекста(ИмяРеквизита);
	КонецЕсли;
#КонецЕсли
	
	Объект = ДанныеКонтекста();
	Ключи = СтрРазделить(ИмяРеквизита, ".");
	Для Инд = 0 По Ключи.Количество() - 2 Цикл
		Объект = Объект[Ключи[Инд]];
	КонецЦикла;
	
	Возврат ЮТОбщий.ЗначениеСтруктуры(Объект, Ключи[Ключи.ВГраница()]);

КонецФункции

// УстановитьЗначениеКонтекста
// Устанавливает значение вложенного контекста, вложенного реквизита контекста
// 
// Параметры:
//  ИмяРеквизита - Строка - Имя реквизита/вложенного контекста
//  Значение - Произвольный - Новое значение реквизита/вложенного контекста
//  УстановитьНаСервер - Булево - Установить также на сервер
Процедура УстановитьЗначениеКонтекста(Знач ИмяРеквизита, Знач Значение, Знач УстановитьНаСервер = Ложь) Экспорт
	
	ДанныеКонтекста = ДанныеКонтекста();
	
	Объект = ДанныеКонтекста;
	Ключи = СтрРазделить(ИмяРеквизита, ".");
	Для Инд = 0 По Ключи.Количество() - 2 Цикл
		Объект = Объект[Ключи[Инд]];
	КонецЦикла;
	
	Объект.Вставить(Ключи[Ключи.ВГраница()], Значение);
	
#Если НЕ Сервер Тогда
	Если УстановитьНаСервер Тогда
		ЮТКонтекстСервер.УстановитьЗначениеКонтекста(ИмяРеквизита, Значение);
	КонецЕсли;
#КонецЕсли
	
КонецПроцедуры

// КонтекстТеста
//  Возвращает структуру, в которой можно хранить данные используемые в тесте
//  Данные живут в рамках одного теста, но доступны в обработчиках событий `ПередКаждымТестом` и `ПослеКаждогоТеста`
//  Например, в контекст можно помещать создаваемые данные, что бы освободить/удалить их в обработчике `ПослеКаждогоТеста`
// Возвращаемое значение:
//  Структура - Контекст теста
//  Неопределено - Если метод вызывается за рамками теста
Функция КонтекстТеста() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаТеста());
	
КонецФункции

// КонтекстНабора
//  Возвращает структуру, в которой можно хранить данные используемые в тестах набора
//  Данные живут в рамках одного набора тестов (данные между клиентом и сервером не синхронизируются)
//  Доступны в каждом тесте набора и в обработчиках событий 
//  	+ `ПередТестовымНабором`
//  	+ `ПослеТестовогоНабора`
//  	+ `ПередКаждымТестом`
//  	+ `ПослеКаждогоТеста`
//  Например, в контекст можно помещать создаваемые данные, что бы освободить/удалить их в обработчике `ПослеКаждогоТеста`
// Возвращаемое значение:
//  Структура - Контекст набора тестов
//  Неопределено - Если метод вызывается за рамками тестового набора
Функция КонтекстНабора() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаНабораТестов());
	
КонецФункции

// КонтекстМодуля
//  Возвращает структуру, в которой можно хранить данные используемые в тестах модуля
//  Данные живут в рамках одного тестового модуля (данные между клиентом и сервером не синхронизируются)
//  Доступны в каждом тесте модуля и в обработчиках событий 
//  Например, в контекст можно помещать создаваемые данные, что бы освободить/удалить их в обработчике `ПослеВсехТестов`
// Возвращаемое значение:
//  Структура - Контекст тестового модуля
//  Неопределено - Если метод вызывается за рамками тестового модуля
Функция КонтекстМодуля() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаМодуля());
	
КонецФункции

Функция ГлобальныеНастройкиВыполнения() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяГлобальныеНастройкиВыполнения());
	
КонецФункции

#КонецОбласти

/////////////////////////////////////////////////////////////////////////////////
// Экспортные процедуры и функции для служебного использования внутри подсистемы
///////////////////////////////////////////////////////////////////////////////// 
#Область СлужебныйПрограммныйИнтерфейс

// КонтекстОшибки
//  Возвращает служебный контекст, содержит дополнительные детали ошибки теста
// 
// Возвращаемое значение:
//  Неопределено, Структура - Контекст ошибки, см. ЮТРегистрацияОшибок.НовыйКонтекстОшибки
Функция КонтекстОшибки() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаОшибки());
	
КонецФункции

// КонтекстПроверки
//  Возвращает служебный контекста, данные выполняемой проверки
// Возвращаемое значение:
//  Неопределено, Структура - Контекст проверки
Функция КонтекстПроверки() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаУтверждений());
	
КонецФункции

// КонтекстЧитателя
//  Возвращает служебный контекста, данные необходимые на этапе загрузки тестов
// Возвращаемое значение:
//  Неопределено, Структура - Контекст проверки
Функция КонтекстЧитателя() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаЧитателя());
	
КонецФункции

// КонтекстЧитателя
//  Возвращает служебный контекста, данные используемые исполнителем тестов
// Возвращаемое значение:
//  см. ЮТИсполнитель.ДанныеКонтекстаИсполнения
Функция КонтекстИсполнения() Экспорт
	
	Возврат ЗначениеКонтекста(ИмяКонтекстаИсполнения());
	
КонецФункции

Функция ОписаниеКонтекста() Экспорт
	
	Описание = Новый Структура;
	
	Возврат Описание;
	
КонецФункции

Процедура УстановитьКонтекстОшибки() Экспорт
	
	ДанныеОшибки = ЮТФабрика.ОписаниеКонтекстаОшибки();
	УстановитьЗначениеКонтекста(ИмяКонтекстаОшибки(), ДанныеОшибки);
	
КонецПроцедуры

Процедура УстановитьКонтекстУтверждений(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаУтверждений(), ДанныеКонтекста);
	
КонецПроцедуры

Процедура УстановитьКонтекстНабораТестов(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаНабораТестов(), ДанныеКонтекста);
	
КонецПроцедуры

Процедура УстановитьКонтекстМодуля(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаМодуля(), ДанныеКонтекста);
	
КонецПроцедуры

Процедура УстановитьКонтекстТеста(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаТеста(), ДанныеКонтекста);
	
КонецПроцедуры

Процедура УстановитьКонтекстЧитателя(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаЧитателя(), ДанныеКонтекста, Истина);
	
КонецПроцедуры

Процедура УстановитьКонтекстИсполнения(Знач ДанныеКонтекста) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяКонтекстаИсполнения(), ДанныеКонтекста, Истина);
	
КонецПроцедуры

Процедура УстановитьГлобальныеНастройкиВыполнения(Знач Настройки) Экспорт
	
	УстановитьЗначениеКонтекста(ИмяГлобальныеНастройкиВыполнения(), Настройки, Истина);
	
КонецПроцедуры

Процедура УдалитьКонтекст() Экспорт
	
#Если Клиент Тогда
	ЮТКонтекстКлиент.УдалитьКонтекст();
#КонецЕсли
	ЮТКонтекстСервер.УдалитьКонтекст();
	
КонецПроцедуры

#КонецОбласти

/////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции, составляющие внутреннюю реализацию модуля 
///////////////////////////////////////////////////////////////////////////////// 
#Область СлужебныеПроцедурыИФункции

Функция ИмяКонтекстаОшибки()
	
	Возврат "ДанныеОшибки";
	
КонецФункции

Функция ИмяКонтекстаУтверждений()
	
	Возврат "КонтекстУтверждения";
	
КонецФункции

Функция ИмяКонтекстаНабораТестов()
	
	Возврат "КонтекстНабора";
	
КонецФункции

Функция ИмяКонтекстаМодуля()
	
	Возврат "КонтекстМодуля";
	
КонецФункции

Функция ИмяКонтекстаТеста()
	
	Возврат "КонтекстТеста";
	
КонецФункции

Функция ИмяКонтекстаЧитателя()
	
	Возврат "КонтекстЧитателя";
	
КонецФункции

Функция ИмяГлобальныеНастройкиВыполнения()
	
	Возврат "ГлобальныеНастройкиВыполнения";
	
КонецФункции

Функция ИмяКонтекстаИсполнения()
	
	Возврат "КонтекстИсполнения";
	
КонецФункции

#КонецОбласти
