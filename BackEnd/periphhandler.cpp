#include "periphhandler.h"

#include <QDebug>

PeriphHandler::PeriphHandler(QObject *parent)
    : QObject(parent),
    m_argonCylinder1Connected(false),
    m_argonCylinder2Connected(false),
    m_autoStStopTissue(false),
    m_neutralElConnected(false),
    m_neutralElDivided(true),
    m_autoSSmode(0),
    m_argonFlowRate(80),
    m_argonRealRate(0),
    m_activCylinderFirst(true),  // По умолчанию активен первый баллон
    m_wirelessPedalCharge(0)
{

}

void PeriphHandler::unitStateHandler(Onyx::UnitState state)
{
	if (m_neutralElConnected != state.neutraElConnected) {
		m_neutralElConnected = state.neutraElConnected;
	   emit neutralElConnectedChanged(m_neutralElConnected);
	}

	bool cylinder1Changed = false;
	bool cylinder2Changed = false;

	if (m_argonCylinder1Connected != state.argonCylinder1) {
		m_argonCylinder1Connected = state.argonCylinder1;
		cylinder1Changed = true;
		emit argonCylinder1ConnectedChanged(m_argonCylinder1Connected);
	}

	if (m_argonCylinder2Connected != state.argonCylinder2) {
		m_argonCylinder2Connected = state.argonCylinder2;
		cylinder2Changed = true;
		emit argonCylinder2ConnectedChanged(m_argonCylinder2Connected);
	}

	// Обновляем реальный расход аргона
	if (m_argonRealRate != state.argonRealRate) {
		m_argonRealRate = state.argonRealRate;
		// qDebug() << "РЕАЛЬНЫЙ РАСХОД: " << m_argonRealRate;
		emit argonRealRateChanged(m_argonRealRate);
	}

	// Автоматическое переключение активного баллона
	if (cylinder1Changed || cylinder2Changed) {
		// Если второй баллон подключён, а первый нет - переключаемся на второй
		if (m_argonCylinder2Connected && !m_argonCylinder1Connected) {
			if (m_activCylinderFirst) {
				setActivCylinderFirst(false);
			}
		}
		// Если первый баллон подключён, а второй нет - переключаемся на первый
		else if (m_argonCylinder1Connected && !m_argonCylinder2Connected) {
			if (!m_activCylinderFirst) {
				setActivCylinderFirst(true);
			}
		}
	}
}

void PeriphHandler::setActivCylinderFirst(bool first)
{
	if (m_activCylinderFirst == first)
		return;

	m_activCylinderFirst = first;
	emit activCylinderFirstChanged(first);
}

bool PeriphHandler::argonCylinder1Connected() const
{
	return m_argonCylinder1Connected;
}

bool PeriphHandler::argonCylinder2Connected() const
{
	return m_argonCylinder2Connected;
}

quint8 PeriphHandler::argonFlowRate() const
{
	return m_argonFlowRate;
}

void PeriphHandler::setArgonFlowRate(quint8 rate)
{
	if (m_argonFlowRate == rate)
		return;

	m_argonFlowRate = rate;
	emit argonFlowRateChanged(rate);
	// TODO: Отправить команду установки расхода в LinkStm при необходимости
}

void PeriphHandler::argonBlow()
{
	// TODO: Отправить команду продувки аргона через LinkStm
	// Например: m_linkStm->sendArgonBlowCommand();
	qDebug() << "Argon blow command triggered";
}

quint8 PeriphHandler::argonRealRate() const
{
	return m_argonRealRate;
}

bool PeriphHandler::activCylinderFirst() const
{
	return m_activCylinderFirst;
}

bool PeriphHandler::enableActivation() const
{
	return m_enableActivation;
}

void PeriphHandler::setEnableActivation(bool enable)
{
	qDebug() << "setEnableActivation(bool enable)" << enable;
	if (m_enableActivation == enable)
		return;

	m_enableActivation = enable;
	emit enableActivationChanged(enable);
}

bool PeriphHandler::activation() const
{
	return m_activation;
}

bool PeriphHandler::neutralElDivided() const
{
	return m_neutralElDivided;
}

void PeriphHandler::setNeutralElDivided(bool divided)
{
	if (m_neutralElDivided == divided)
		return;

	m_neutralElDivided = divided;
	emit neutralElDividedChanged(divided);
}

bool PeriphHandler::neutralElConnected() const
{
	return m_neutralElConnected;
}

void PeriphHandler::setArgonRealRate(quint8 rate)
{
	if (m_argonRealRate == rate)
		return;

	m_argonRealRate = rate;
	emit argonRealRateChanged(rate);
}
