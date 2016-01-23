#ifndef _CARD_CONTAINER_H
#define _CARD_CONTAINER_H

class CardItem;
class ClientPlayer;

#include "qsan-selectable-item.h"
#include "carditem.h"
#include "generic-cardcontainer-ui.h"

#include <QStack>

class CloseButton : public QSanSelectableItem
{
    Q_OBJECT

public:
    CloseButton();

protected:
    virtual void mousePressEvent(QGraphicsSceneMouseEvent *event);
    virtual void mouseReleaseEvent(QGraphicsSceneMouseEvent *event);

signals:
    void clicked();
};

class CardContainer : public GenericCardContainer
{
    Q_OBJECT

public:
    explicit CardContainer();
    virtual QList<CardItem *> removeCardItems(const QList<int> &card_ids, Player::Place place);
    int getFirstEnabled() const;
    void startChoose();
    void startGongxin(const QList<int> &enabled_ids);
    void addCloseButton();
    void view(const ClientPlayer *player);
    virtual QRectF boundingRect() const;
    ClientPlayer *m_currentPlayer;
    virtual void paint(QPainter *, const QStyleOptionGraphicsItem *, QWidget *);
    bool retained();

public slots:
    void fillCards(const QList<int> &card_ids = QList<int>(), const QList<int> &disabled_ids = QList<int>());
    void clear();
    void freezeCards(bool is_disable);

protected:
    QRectF _m_boundingRect;
    virtual bool _addCardItems(QList<CardItem *> &card_items, const CardsMoveStruct &moveInfo);

private:
    QList<CardItem *> items;
    CloseButton *close_button;
    QPixmap _m_background;
    QStack<QList<CardItem *> > items_stack;
    QStack<bool> retained_stack;

    void _addCardItem(int card_id, const QPointF &pos);

private slots:
    void grabItem();
    void chooseItem();
    void gongxinItem();

signals:
    void item_chosen(int card_id);
    void item_gongxined(int card_id);
};

class GuanxingBox : public QSanSelectableItem
{
    Q_OBJECT

public:
    GuanxingBox();
    void clear();
    void reply();

public slots:
    void doGuanxing(const QList<int> &card_ids, bool up_only);
    void adjust();

private:
    QList<CardItem *> up_items, down_items;
    bool up_only;

    static const int start_x = 76;
    static const int start_y1 = 105;
    static const int start_y2 = 249;
    static const int middle_y = 173;
    static const int skip = 102;
};

#endif

