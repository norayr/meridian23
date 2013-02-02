#include <QGeoCoordinate>
//#include <QtCore/QCoreApplication>
#include "loc.h"
//#include <stdio.h>
#include <iostream>

locator::locator(QObject * parent)
{
//	QGeoPositionInfoSource*	m_pli= NULL;                                                                  
		m_pli=QGeoPositionInfoSource::createDefaultSource(this);
		m_pli->setPreferredPositioningMethods(QGeoPositionInfoSource::SatellitePositioningMethods);
		connect(m_pli,SIGNAL(positionUpdated(QGeoPositionInfo)),this,SLOT(positionUp(QGeoPositionInfo)));
		m_pli->startUpdates();
//	qreal latitude = 0.0;
//	qreal longitude = 0.0;
// startLocationAPI();
}
locator::~locator()
{
}
//void locator::startLocationAPI()                                                                  
//{
//	if(!m_pli)
//	{
//		m_pli=QGeoPositionInfoSource::createDefaultSource(this);
//		m_pli->setPreferredPositioningMethods(QGeoPositionInfoSource::SatellitePositioningMethods);
//		connect(m_pli,SIGNAL(positionUpdated(QGeoPositionInfo)),this,SLOT(positionUp(QGeoPositionInfo)));
//		m_pli->startUpdates();
//	}
//}
void locator::positionUp(QGeoPositionInfo gpi)
	                                                                  
{
//	printf ("entered positionUP\n");
	if(gpi.isValid())
	{
//		printf ("gpi is valid\n");
		QGeoCoordinate gc=gpi.coordinate();
	 latitude = gc.latitude();
		 longitude = gc.longitude();
		 std::cout << ("lon = ") << std::endl;
		 std::cout << ((float)longitude) << std::endl;
		 std::cout << ("lat = ") << std::endl;
		 std::cout << ((float)latitude) << std::endl;
//		 printf ("lon = \n");
//		 fflush(stdout);
//		 printf ("%f\n", (float)longitude);
//		 fflush(stdout);
//		 printf ("lat = \n");
//		 fflush(stdout);
//		 printf ("%f\n", (float)latitude);
//		 fflush(stdout);
	}
}

