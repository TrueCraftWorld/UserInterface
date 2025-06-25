#include "socketmodeeditor.h"

SocketModeEditor::SocketModeEditor(SocketModel *model, QObject *parent)
    : QObject{parent},
    m_model{model}
{

}

void SocketModeEditor::initialize(const QString &socket, const QString &mode)
{
    m_modeNames = m_model->modeNames(socket, mode);
    m_originalParameters = m_model->modeParam(socket, mode);
    m_socketName = socket;
    m_currentModeIndex = m_modeNames.indexOf(mode);
    m_currentParameters = m_originalParameters;
    emit parametersLoaded();
}

void SocketModeEditor::loadModeParameters(int modeIndex)
{
    if (modeIndex >= m_modeNames.size())
        retrun;
    m_currentParameters = m_model->modeParam(m_socketName, m_modeNames.at(modeIndex));
}

void SocketModeEditor::updateCurrentParameters(const QVariantMap ms)
{
    if (isParamsEqual(m_currentParameters, ms))
        return;
    m_currentParameters = ms;
    emit currentParamsChanged();
}

void SocketModeEditor::updateParameters(const QString &paramName, const QVariant &value)
{
    // if (paramName)
    //Пока что просто присваиваем, но по-хорошему нужна проверка что добавляем параметры с нормальными
    //ключами и проверять типа данных на соответствие хранимым, а то из QMLнапихать сможем многовато лишнего
    
    m_currentParameters[paramName] = value;
    emit currentParamsChanged();
}

void SocketModeEditor::commitChanges()
{
    if (hasChanges())
        emit editingFinished(true);

    const bool success =
            (m_model->commitModeChange(m_socketName,
                                       m_modeNames.at(m_currentModeIndex),
                                       m_currentParameters));
    emit editingFinished(success);
}

void SocketModeEditor::rollBack()
{
    emit editingFinished(false);
}

QStringList SocketModeEditor::modeNames() const
{
    return m_modeNames;
}

QVariantMap SocketModeEditor::currentMode() const
{
    return m_currentParameters;
}

int SocketModeEditor::currentModeIndex() const
{
    return m_currentModeIndex;
}

void SocketModeEditor::setCurrentModeIndex(int index)
{
    if (m_model->rowCount(QModelIndex()) >= index)
        m_currentModeIndex = index;
}

bool SocketModeEditor::hasChanges() const
{
    return m_currentModeIndex != m_originalModeIndex ||
           !isParamsEqual(m_currentParameters, m_originalParameters);
}

QVariantMap SocketModeEditor::fetchModeParameters(int m_socketRow, int modeIndex)
{
    if (modeIndex >= m_modeNames.size())
        return QVariantMap();

    return m_model->modeParam(m_socketName, m_modeNames.at(modeIndex));
}

bool SocketModeEditor::isParamsEqual(const QVariantMap &a, const QVariantMap &b) const
{
    if (a.size() != b.size())
        return false;

    QStringList tempA = a.keys();
    QStringList tempB = a.keys();

    if (tempA.size() != tempB.size())
        return false;

    std::sort(tempA.begin(), tempA.end());
    std::sort(tempB.begin(), tempB.end());

    if (tempA != tempB)
        return false;
    bool isEqual = true;
    for (int idx = 0; idx < tempA.size(); ++idx) {
        const QVariant& aValueRef = a.value(tempA.at(idx));
        const QVariant& bValueRef = b.value(tempB.at(idx));
        if (aValueRef.typeName() !=
            bValueRef.typeName() ) {
            isEqual = false;
            break;
        }
        // тут нужна конверсия названия полей интересующих нас в типы для явного сравнения
        //
        // if (aValueRef.() != bValueRef.value())
    }
    return isEqual;

}
