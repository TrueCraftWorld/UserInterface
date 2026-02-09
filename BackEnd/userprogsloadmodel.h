#ifndef USERPROGSLOADMODEL_H
#define USERPROGSLOADMODEL_H

#include <QAbstractListModel>
#include <QObject>

#include <map>
#include <vector>

class UserProg
{
public:
	UserProg() {}
	int id() const;
	QString name() const;

private:
	int m_id;
	QString m_name;
};

class UserProgsLoadModel : public QAbstractListModel
{
	Q_OBJECT
public:
	enum UserProgRoles {
		ProgId = Qt::UserRole+1,
		ProgName
	};
	Q_ENUM(UserProgRoles)
	UserProgsLoadModel();

	void set_items(const std::map<int,UserProg>&& progs);

	// QAbstractItemModel interface
public:
	virtual int rowCount(const QModelIndex &parent) const override;
	virtual int columnCount(const QModelIndex &parent) const override;
	virtual QVariant data(const QModelIndex &index, int role) const override;
	virtual bool removeColumns(int column, int count, const QModelIndex &parent) override;

private:
	virtual QHash<int, QByteArray> roleNames() const override final;
	std::map<int, UserProg> m_progs;
	std::vector<int> m_keys;
};

#endif // USERPROGSLOADMODEL_H
