#include "socketreader.h"


EshfProgStringBuilder::EshfProgStringBuilder()
{

}

QStringList EshfProgStringBuilder::makeModeString(int socketNum, int pageNum)
{
	QStringList res;
	return res;
}

void EshfProgStringBuilder::setState(const std::vector<std::map<int, SockPtr> > &sockets,
                                    const std::vector<std::map<int, Instrument> > &instrs)
{
	m_instrs = instrs;
	m_sockets = sockets;
}
