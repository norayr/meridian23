#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>
#include <QObject>
QTM_USE_NAMESPACE

class locator : public QObject

{
	Q_OBJECT

public:
	qreal latitude;
	qreal longitude;
	locator(QObject * parent = 0);
	~locator();
signals:
	void positionUpdated(QGeoPositionInfo gpi);
public slots:
	void positionUp(QGeoPositionInfo gpi);
private:
	void startLocationAPI();
private:
	QGeoPositionInfoSource* m_pli;


};
