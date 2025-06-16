#include "socketmodel.h"

SocketModel::SocketModel(QObject *parent)
    : QAbstractListModel{parent}
{}


int SocketModel::rowCount(const QModelIndex &parent) const
{
}

QVariant SocketModel::data(const QModelIndex &index, int role) const
{
}

bool SocketModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
}
