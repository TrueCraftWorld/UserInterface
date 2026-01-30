#include "userprogsloadmodel.h"

// #include <QMetaObject>
#include <QQmlEngine>



UserProgsLoadModel::UserProgsLoadModel()
{

}

void UserProgsLoadModel::set_items(const std::map<int, UserProg> &&progs)
{
	beginResetModel();
	m_progs = std::move(progs);
	m_keys.clear();
	m_keys.reserve(m_progs.size());
	for (const auto& prog : m_progs) {
		m_keys.emplace_back(prog.first);
	}
	endResetModel();
}

int UserProgsLoadModel::rowCount(const QModelIndex &parent) const
{
	return m_progs.size();
}

int UserProgsLoadModel::columnCount(const QModelIndex &parent) const
{
	Q_UNUSED(parent)
	return 1; // показывать собираемся только имя, id базы - для внутренних вызовов
}

QVariant UserProgsLoadModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid())
		return QVariant();

	if (index.row() >= m_progs.size())
		return QVariant();

	const auto& item = m_progs.at(m_keys.at(index.row()));

	switch (role) {
	case Qt::DisplayRole:
	case ProgName:
		return item.name();
	case ProgId:
		return item.id();
		break;
	default:
		break;
	}
	return QVariant();

}

bool UserProgsLoadModel::removeColumns(int column, int count, const QModelIndex &parent)
{
	return true;
}

QHash<int, QByteArray> UserProgsLoadModel::roleNames() const
{
	QMetaEnum metaEnum = QMetaEnum::fromType<UserProgRoles>();
	QHash<int, QByteArray> roles;
	for (int k = 0; k < metaEnum.keyCount(); k++)
	{
		int roleKey = metaEnum.value(k);
		QString roleName = metaEnum.valueToKey(roleKey);
		roleName = roleName.toLower();
		roles.insert(roleKey, roleName.toUtf8());
	}
	return roles;
}

int UserProg::id() const
{
	return m_id;
}

QString UserProg::name() const
{
	return m_name;
}
