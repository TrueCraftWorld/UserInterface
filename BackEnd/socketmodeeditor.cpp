#include "socketmodeeditor.h"

SocketModeEditor::SocketModeEditor(SocketModel *model, QObject *parent)
    : QObject{parent},
    m_model{model}
{

}

void SocketModeEditor::initialize(int socket, int mode, bool isCoag)
{
    if (socket == -1|| mode == -1)
        return;
    m_isCoag = isCoag;
    m_socketID = socket;
    m_modeNames = m_model->modeNames(socket, isCoag);
    m_originalParameters = m_model->modeParam(socket, mode, isCoag);
    m_instrList = m_model->instrumNames(socket, mode, isCoag);

    m_socketName = m_model->index(socket,0).data(SocketModel::SocketName).toString();
    m_originalModeIndex = mode;

    m_currentModeIndex = m_originalModeIndex;
    m_currentParameters = m_originalParameters;
    m_hasChanges = false;
    emit parametersLoaded();
    emit currentParamsChanged();
}

void SocketModeEditor::loadModeParameters(int modeIndex)
{
    if (modeIndex >= m_modeNames.size())
        return;
    m_currentParameters = m_model->modeParam(m_socketID, /*m_modeNames.at*/(modeIndex), m_isCoag);
}

void SocketModeEditor::updateCurrentParameters(const QVariantMap ms)
{
    if (isParamsEqual(m_currentParameters, ms))
        return;
    m_currentParameters = ms;
            checkChanges();
    emit currentParamsChanged();
}

void SocketModeEditor::updateParameter(const QString &paramName, const QVariant &value)
{
    // if (paramName)
    //Пока что просто присваиваем, но по-хорошему нужна проверка что добавляем параметры с нормальными
    //ключами и проверять типа данных на соответствие хранимым, а то из QMLнапихать сможем многовато лишнего
    
    m_currentParameters[paramName] = value;
            checkChanges();
    emit currentParamsChanged();
}

void SocketModeEditor::commitChanges()
{
    // if (!checkChanges())
        // emit editingFinished(true);

    const bool success =
            (m_model->commitModeChange(m_socketID,
                                       // m_modeNames.at(m_currentModeIndex),
                                       m_currentModeIndex,
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

QString SocketModeEditor::socketName() const
{
    return m_socketName;
}

int SocketModeEditor::currentModeIndex() const
{
    return m_currentModeIndex;
}

void SocketModeEditor::setCurrentModeIndex(int index)
{
    if (m_modeNames.size() >= index) {
        m_currentModeIndex = index;
        loadModeParameters(index);
        checkChanges();
        emit currentModeIndexChanged();
        emit currentParamsChanged();
    }
}

bool SocketModeEditor::checkChanges()
{
    bool tmp = ( m_currentModeIndex != m_originalModeIndex /*||
           !isParamsEqual(m_currentParameters, m_originalParameters)*/
            || m_currentParameters.value("currentpower").toInt()
                != m_originalParameters.value("currentpower").toInt());

    if (tmp && m_hasChanges != tmp) {
        m_hasChanges = tmp;
        emit hasChangesChanged();
    }
    return tmp;
}

QStringList SocketModeEditor::instrList() const
{
    return m_instrList;
}

QVariantMap SocketModeEditor::fetchModeParameters(int modeIndex)
{
    if (modeIndex >= m_modeNames.size())
        return QVariantMap();

    return m_model->modeParam(m_socketID, /*m_modeNames.at*/(modeIndex), m_isCoag);
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

bool SocketModeEditor::hasChanges() const
{
    return m_hasChanges;
}

int SocketModeEditor::currentInstrIndex() const
{
    return m_currentInstrIndex;
    // return m_currentParameters.value("instrindex").toInt();
}

void SocketModeEditor::setCurrentInstrIndex(int newCurrentInstrIndex)
{
    m_currentInstrIndex = newCurrentInstrIndex;
    updateParameter("instrindex", m_currentInstIndex);
    emit currentInstrChanged();
}
