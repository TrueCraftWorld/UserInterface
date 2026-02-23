#ifndef PROGLOADER_H
#define PROGLOADER_H

#include <QObject>
#include <QPointer>
#include <map>
// #include <array>

#include "BackEnd/progloaderbase.h"
#include "instrument.h"
#include "databasereader.h"
#include "socketmodel.h"
// #include "userprogsloadmodel.h"
// bi1CutInstr = "0", bi1CutMode = "1000", bi1CutPower = "1";



class ProgLoader : public QObject
{
	Q_OBJECT
public:

	enum progType {
		ptRecom = 0,
		ptUser,
		ptService,
		ptCount
	};

	explicit ProgLoader(QObject *parent = nullptr);
	/**
	 * @brief Сохраняет текущее состояние всех сокетов в БД (таблица Lists, id=1000)
	 */
	
public slots:
	void slotSaveCurrentState();
	
signals:
	
public:
	
	bool readPreviousSocketSettings();
	
	void defaultSocketInit(bool clear = true);
	// void removeSubProg(int index);
	/**
	 * @brief ControlCenter::programmLoadSocketInit
	 * @param progId
	 * @details я тут с ума сойду - вся эта функция за раз в голове не помещается
	 * Шаг 1 - получить строки таблицы Lists, с соответствующими id (каждая строка - 1 рабочий экран)
	 * Шаг 2 - поличить строки таблицы EnabledMods, с соответствующими id
	 *         (каждая строка - 1 разрещённый режим)
	 * Шаг 3 - поличить строки таблицы EnabledInstr, с соответствующими id
	 *         (каждая строка - 1 разрещённый инструмент)
	 * Шаг 4 - из таблицы Instrum получить список допустимых инструментов
	 *         для каждого режима в списке режимов (Шаг 2)
	 * Шаг 5 - Проредить полученный список инструментов оставив в нём только
	 *         те, которые разрешены в данной программе (Шаг 3)
	 * Шаг 6 - Поселедовательная инициализация полусокетов по строкам из (Шаг 1)
	 *         Если сокет включён:
	 *         6.1 - для каждого полусокета прореживание списка режимов
	 *         6.2 - для каждого полусокета прореживания списка инструментов
	 *         6.3 инициализация сокета полученным списком допустимыз режимов и инструментов
	 *         6.4 установка режима, мощностии и инструмента по умолчанию
	 */
	bool programmLoadSocketInit(int progId, bool clear = true);
	
	/**
	 * @brief getCategories получение списка доспуных программ в категории
	 * @param scopeID
	 * @return
	 */
	std::map<int, QString> getProgs(int scopeID);
	
	std::map<int, QString> getCategories();
	
	std::map<int, QString> getUserProgList();
	// QMap<int, QString> getUserProgList();
	
	void saveUserProg(const QString& name);
	
	void deleteUserProg(int id);
	
	/**
	 * @brief Загружает последнее сохранённое состояние из БД
	 */
	bool loadCurrentState();
	
	std::map<int, std::map<int, Onyx::InstrInfo>> getConstraints(const QList<int> &idList);
	
	void setSocketModelPtr(QSharedPointer<SocketModel> newSocketModelPtr);

	int addUserScope(const QString& name);
	
public slots:
	bool loadUserProg(int userProgId);
	
private:
	std::map<int, QString> getProgList(bool isUser = false);
	std::map<int, InstrPtr> getInstrums();
	void saveProg(const QString& name = "");
	
	QPointer<DataBaseReader> m_dbReaderPtr;
	QSharedPointer<SocketModel> m_socketModelPtr;

	// std::map<int, QSharedPointer<ProgLoaderBase>> m_loaders;
	// QPointer<ProgLoaderBase> loader = nullptr;
	progType m_curLoaderType = ptRecom;

	ProgLoaderBase* getLoader(progType type);
};

#endif // PROGLOADER_H
