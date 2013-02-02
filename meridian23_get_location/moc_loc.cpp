/****************************************************************************
** Meta object code from reading C++ file 'loc.h'
**
** Created: Tue Sep 4 17:21:04 2012
**      by: The Qt Meta Object Compiler version 62 (Qt 4.7.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "loc.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'loc.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 62
#error "This file was generated using the moc from 4.7.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_locator[] = {

 // content:
       5,       // revision
       0,       // classname
       0,    0, // classinfo
       2,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      13,    9,    8,    8, 0x05,

 // slots: signature, parameters, type, tag, flags
      47,    9,    8,    8, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_locator[] = {
    "locator\0\0gpi\0positionUpdated(QGeoPositionInfo)\0"
    "positionUp(QGeoPositionInfo)\0"
};

const QMetaObject locator::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_locator,
      qt_meta_data_locator, 0 }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &locator::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *locator::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *locator::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_locator))
        return static_cast<void*>(const_cast< locator*>(this));
    return QObject::qt_metacast(_clname);
}

int locator::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: positionUpdated((*reinterpret_cast< QGeoPositionInfo(*)>(_a[1]))); break;
        case 1: positionUp((*reinterpret_cast< QGeoPositionInfo(*)>(_a[1]))); break;
        default: ;
        }
        _id -= 2;
    }
    return _id;
}

// SIGNAL 0
void locator::positionUpdated(QGeoPositionInfo _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
