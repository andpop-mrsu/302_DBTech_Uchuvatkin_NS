-- Создание базы данных для стоматологической клиники

-- Таблица специализаций врачей
CREATE TABLE Specializations (
    specialization_id INTEGER PRIMARY KEY AUTOINCREMENT,
    specialization_name TEXT NOT NULL UNIQUE
);

-- Таблица врачей
CREATE TABLE Doctors (
    doctor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    hire_date DATE NOT NULL,
    dismissal_date DATE DEFAULT NULL,
    salary_percentage REAL NOT NULL CHECK(salary_percentage > 0 AND salary_percentage <= 100),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1))
);

-- Таблица связи врачей и специализаций
CREATE TABLE DoctorSpecializations (
    doctor_id INTEGER NOT NULL,
    specialization_id INTEGER NOT NULL,
    PRIMARY KEY (doctor_id, specialization_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    FOREIGN KEY (specialization_id) REFERENCES Specializations(specialization_id) ON DELETE CASCADE
);

-- Таблица категорий услуг
CREATE TABLE ServiceCategories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE,
    specialization_id INTEGER NOT NULL,
    FOREIGN KEY (specialization_id) REFERENCES Specializations(specialization_id) ON DELETE RESTRICT
);

-- Таблица услуг
CREATE TABLE Services (
    service_id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_name TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK(duration_minutes > 0),
    base_price REAL NOT NULL CHECK(base_price > 0),
    FOREIGN KEY (category_id) REFERENCES ServiceCategories(category_id) ON DELETE RESTRICT
);

-- Таблица записей на прием
CREATE TABLE Appointments (
    appointment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    doctor_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    patient_name TEXT NOT NULL,
    patient_phone TEXT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK(status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
    notes TEXT DEFAULT NULL,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE RESTRICT
);

-- Таблица выполненных процедур
CREATE TABLE Procedures (
    procedure_id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER UNIQUE NOT NULL,
    doctor_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    completion_datetime DATETIME NOT NULL,
    actual_price REAL NOT NULL CHECK(actual_price > 0),
    report TEXT DEFAULT NULL,
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES Services(service_id) ON DELETE RESTRICT
);

-- Индексы для оптимизации
CREATE INDEX idx_doctors_active ON Doctors(is_active);
CREATE INDEX idx_appointments_datetime ON Appointments(appointment_datetime);
CREATE INDEX idx_appointments_doctor ON Appointments(doctor_id);
CREATE INDEX idx_appointments_status ON Appointments(status);
CREATE INDEX idx_procedures_doctor ON Procedures(doctor_id);
CREATE INDEX idx_procedures_completion_date ON Procedures(completion_datetime);

-----------------------------------------------------------------------
-- ЗАПОЛНЕНИЕ ТАБЛИЦ ТЕСТОВЫМИ ДАННЫМИ
-----------------------------------------------------------------------

-- Специализации
INSERT INTO Specializations (specialization_name) VALUES
('Терапевт'),
('Хирург'),
('Ортодонт'),
('Пародонтолог'),
('Ортопед');

-- Врачи
INSERT INTO Doctors (full_name, hire_date, dismissal_date, salary_percentage, is_active) VALUES
('Соколова Анна Викторовна', '2018-03-10', NULL, 42.5, 1),
('Лебедев Дмитрий Сергеевич', '2019-11-15', NULL, 38.0, 1),
('Воробьева Екатерина Игоревна', '2020-06-22', NULL, 35.0, 1),
('Громов Артем Олегович', '2017-09-05', '2023-12-01', 40.0, 0),
('Зайцева Ольга Михайловна', '2021-02-14', NULL, 36.5, 1);

-- Связь врачей и специализаций
INSERT INTO DoctorSpecializations (doctor_id, specialization_id) VALUES 
(1, 1), (1, 4),
(2, 2),
(3, 3),
(4, 2), (4, 1),
(5, 5), (5, 1);

-- Категории услуг
INSERT INTO ServiceCategories (category_name, specialization_id) VALUES
('Терапевтическое лечение', 1),
('Хирургические операции', 2),
('Имплантация', 2),
('Исправление прикуса', 3),
('Лечение десен', 4),
('Протезирование', 5);

-- Услуги
INSERT INTO Services (service_name, category_id, duration_minutes, base_price) VALUES
('Консультация и осмотр', 1, 30, 1000.00),
('Лечение кариеса', 1, 60, 3500.00),
('Чистка зубов', 1, 45, 4500.00),
('Эндодонтическое лечение', 1, 90, 5500.00),
('Удаление зуба простое', 2, 30, 2500.00),
('Удаление зуба сложное', 2, 60, 6500.00),
('Резекция верхушки корня', 2, 75, 12000.00),
('Установка имплантата', 3, 120, 35000.00),
('Костная пластика', 3, 90, 28000.00),
('Установка брекет-системы', 4, 60, 40000.00),
('Коррекция брекет-системы', 4, 30, 2500.00),
('Изготовление и установка элайнера', 4, 45, 65000.00),
('Лечение пародонтита', 5, 60, 8000.00),
('Закрытый кюретаж', 5, 45, 6000.00),
('Изготовление коронки', 6, 0, 15000.00),
('Установка коронки', 6, 40, 5000.00),
('Изготовление и установка винира', 6, 60, 25000.00);

-- Записи на прием
INSERT INTO Appointments (doctor_id, service_id, patient_name, patient_phone, appointment_datetime, status) VALUES
(1, 2, 'Николаев Игорь Петрович', '+79015551234', '2024-12-10 09:00:00', 'scheduled'),
(1, 3, 'Мельникова Светлана Дмитриевна', '+79025552345', '2024-12-10 11:00:00', 'scheduled'),
(2, 6, 'Крылов Андрей Владимирович', '+79035553456', '2024-12-11 10:30:00', 'scheduled'),
(3, 11, 'Тихонова Мария Сергеевна', '+79045554567', '2024-12-12 14:00:00', 'scheduled'),
(5, 17, 'Белов Павел Александрович', '+79055555678', '2024-12-13 16:00:00', 'scheduled'),
(1, 1, 'Фролова Татьяна Олеговна', '+79065556789', '2024-12-03 10:00:00', 'completed'),
(2, 5, 'Гаврилов Роман Ильич', '+79075557890', '2024-12-04 13:00:00', 'completed'),
(3, 12, 'Данилова Алина Максимовна', '+79085558901', '2024-12-05 15:30:00', 'completed'),
(5, 18, 'Ершова Виктория Андреевна', '+79095559012', '2024-12-06 11:00:00', 'completed'),
(2, 7, 'Семенов Григорий Леонидович', '+79105550123', '2024-12-07 09:00:00', 'cancelled'),
(4, 8, 'Лазарев Иван Константинович', '+79125552345', '2023-10-20 09:00:00', 'completed'),
(4, 4, 'Полякова Надежда Борисовна', '+79135553456', '2023-11-05 14:00:00', 'completed');

-- Выполненные процедуры
INSERT INTO Procedures (appointment_id, doctor_id, service_id, completion_datetime, actual_price, report) VALUES
(6, 1, 1, '2024-12-03 10:35:00', 1000.00, 'Осмотр, назначена профессиональная гигиена'),
(7, 2, 5, '2024-12-04 13:40:00', 2500.00, 'Удален разрушенный зуб'),
(8, 3, 12, '2024-12-05 16:00:00', 65000.00, 'Изготовлен набор элайнеров'),
(9, 5, 18, '2024-12-06 11:50:00', 5000.00, 'Установлена коронка'),
(11, 4, 8, '2023-10-20 10:30:00', 35000.00, 'Установлен имплантат'),
(12, 4, 4, '2023-11-05 15:30:00', 5500.00, 'Эндодонтическое лечение');