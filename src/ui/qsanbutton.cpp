#include "qsanbutton.h"
#include "clientplayer.h"
#include "skin-bank.h"
#include "engine.h"
#include "roomscene.h"

#include <QPixmap>
#include <qbitmap.h>
#include <QPainter>
#include <QGraphicsSceneHoverEvent>

QSanButton::QSanButton(QGraphicsItem *parent) : QGraphicsObject(parent)
{
    _m_state = S_STATE_UP;
    _m_style = S_STYLE_PUSH;
    _m_mouseEntered = false;
    setSize(QSize(0, 0));
    setAcceptHoverEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton);
}

QSanButton::QSanButton(const QString &groupName, const QString &buttonName, QGraphicsItem *parent)
    : QGraphicsObject(parent)
{
    _m_state = S_STATE_UP;
    _m_style = S_STYLE_PUSH;
    _m_groupName = groupName;
    _m_buttonName = buttonName;
    _m_mouseEntered = false;

    for (int i = 0; i < (int)S_NUM_BUTTON_STATES; i++)
        _m_bgPixmap[i] = G_ROOM_SKIN.getButtonPixmap(groupName, buttonName, (QSanButton::ButtonState)i);
    setSize(_m_bgPixmap[0].size());

    setAcceptHoverEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton);
}

void QSanButton::click()
{
    if (isEnabled())
        _onMouseClick(true);
}

QRectF QSanButton::boundingRect() const
{
    return QRectF(0, 0, _m_size.width(), _m_size.height());
}

void QSanButton::paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *)
{
    painter->drawPixmap(0, 0, _m_bgPixmap[(int)_m_state]);
}

void QSanButton::setSize(QSize newSize)
{
    _m_size = newSize;
    if (_m_size.width() == 0 || _m_size.height() == 0) {
        _m_mask = QRegion();
        return;
    }
    Q_ASSERT(!_m_bgPixmap[0].isNull());
    QPixmap pixmap = _m_bgPixmap[0];
    _m_mask = QRegion(pixmap.mask().scaled(newSize));
}

void QSanButton::setRect(QRect rect)
{
    setSize(rect.size());
    setPos(rect.topLeft());
}

void QSanButton::setStyle(ButtonStyle style)
{
    _m_style = style;
}

void QSanButton::setEnabled(bool enabled)
{
    bool changed = (enabled != isEnabled());
    if (!changed) return;
    if (enabled) {
        setState(S_STATE_UP);
        _m_mouseEntered = false;
    }
    QGraphicsObject::setEnabled(enabled);
    if (!enabled) setState(S_STATE_DISABLED);
    update();
    emit enable_changed();
}

void QSanButton::setState(QSanButton::ButtonState state)
{
    if (this->_m_state != state) {
        this->_m_state = state;
        update();
    }
}

bool QSanButton::insideButton(QPointF pos) const
{
    return _m_mask.contains(QPoint(pos.x(), pos.y()));
}

void QSanButton::hoverEnterEvent(QGraphicsSceneHoverEvent *event)
{
    if (_m_state == S_STATE_DISABLED) return;
    QPointF point = event->pos();
    if (_m_mouseEntered || !insideButton(point)) return; // fake event;

    Q_ASSERT(_m_state != S_STATE_HOVER);
    _m_mouseEntered = true;
    if (_m_state == S_STATE_UP)
        setState(S_STATE_HOVER);
}

void QSanButton::hoverLeaveEvent(QGraphicsSceneHoverEvent *)
{
    if (_m_state == S_STATE_DISABLED) return;
    if (!_m_mouseEntered) return;

    Q_ASSERT(_m_state != S_STATE_DISABLED);
    if (_m_state == S_STATE_HOVER)
        setState(S_STATE_UP);
    _m_mouseEntered = false;
}

void QSanButton::hoverMoveEvent(QGraphicsSceneHoverEvent *event)
{
    QPointF point = event->pos();
    if (insideButton(point)) {
        if (!_m_mouseEntered) hoverEnterEvent(event);
    } else {
        if (_m_mouseEntered) hoverLeaveEvent(event);
    }
}

void QSanButton::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    QPointF point = event->pos();
    if (!insideButton(point)) return;

    Q_ASSERT(_m_state != S_STATE_DISABLED);
    if (_m_style == S_STYLE_TOGGLE) return;
    setState(S_STATE_DOWN);
}

void QSanButton::_onMouseClick(bool inside)
{
    if (_m_style == S_STYLE_PUSH)
        setState(S_STATE_UP);
    else if (_m_style == S_STYLE_TOGGLE) {
        if (_m_state == S_STATE_HOVER)
            _m_state = S_STATE_UP; // temporarily set, do not use setState!

        if (_m_state == S_STATE_DOWN && inside)
            setState(S_STATE_UP);
        else if (_m_state == S_STATE_UP && inside)
            setState(S_STATE_DOWN);
    }
    update();

    if (inside) emit clicked();
}

void QSanButton::mouseReleaseEvent(QGraphicsSceneMouseEvent *event)
{
    Q_ASSERT(_m_state != S_STATE_DISABLED);
    QPointF point = event->pos();
    bool inside = insideButton(point);
    _onMouseClick(inside);
}

bool QSanButton::isDown()
{
    return (_m_state == S_STATE_DOWN);
}

void QSanButton::redraw()
{
    for (int i = 0; i < (int)S_NUM_BUTTON_STATES; ++i) {
        _m_bgPixmap[i] = G_ROOM_SKIN.getButtonPixmap(_m_groupName,
                                                    _m_buttonName, (const ButtonState &)i);
    }

    setSize(_m_bgPixmap[0].size());
}

QSanSkillButton::QSanSkillButton(QGraphicsItem *parent)
    : QSanButton(parent)
{
    _m_groupName = QSanRoomSkin::S_SKIN_KEY_BUTTON_SKILL;
    _m_emitActivateSignal = false;
    _m_emitDeactivateSignal = false;
    _m_canEnable = true;
    _m_canDisable = true;
    _m_skill = NULL;
    _m_viewAsSkill = NULL;
    connect(this, SIGNAL(clicked()), this, SLOT(onMouseClick()));
    _m_skill = NULL;
}

void QSanSkillButton::_setSkillType(SkillType type)
{
    _m_skillType = type;
}

void QSanSkillButton::onMouseClick()
{
    if (_m_skill == NULL) return;
    if ((_m_style == S_STYLE_TOGGLE && isDown() && _m_emitActivateSignal) || _m_style == S_STYLE_PUSH) {
        emit skill_activated();
        emit skill_activated(_m_skill);
    } else if (!isDown() && _m_emitDeactivateSignal) {
        emit skill_deactivated();
        emit skill_deactivated(_m_skill);
    }
}

void QSanSkillButton::setSkill(const Skill *skill)
{
    Q_ASSERT(skill != NULL);
    _m_skill = skill;
    // This is a nasty trick because the server side decides to choose a nasty design
    // such that sometimes the actual viewas skill is nested inside a trigger skill.
    // Since the trigger skill is not relevant, we flatten it before we create the button.
    _m_viewAsSkill = ViewAsSkill::parseViewAsSkill(_m_skill);
    if (skill == NULL) skill = _m_skill;

    Skill::Frequency freq = skill->getFrequency(Self);
    if (freq == Skill::Frequent
        || (freq == Skill::NotFrequent && skill->inherits("TriggerSkill") && !skill->inherits("WeaponSkill")
        && !skill->inherits("ArmorSkill") && _m_viewAsSkill == NULL)) {
        setStyle(QSanButton::S_STYLE_TOGGLE);
        setState(freq == Skill::Frequent ? QSanButton::S_STATE_DOWN : QSanButton::S_STATE_UP);
        _setSkillType(QSanInvokeSkillButton::S_SKILL_FREQUENT);
        _m_emitActivateSignal = false;
        _m_emitDeactivateSignal = false;
        _m_canEnable = true;
        _m_canDisable = false;
    } else if (freq == Skill::Limited || freq == Skill::NotFrequent) {
        setState(QSanButton::S_STATE_DISABLED);
        if (skill->isAttachedLordSkill())
            _setSkillType(QSanInvokeSkillButton::S_SKILL_ATTACHEDLORD);
        else if (freq == Skill::Limited)
            _setSkillType(QSanInvokeSkillButton::S_SKILL_ONEOFF_SPELL);
        else
            _setSkillType(QSanInvokeSkillButton::S_SKILL_PROACTIVE);

        setStyle(QSanButton::S_STYLE_TOGGLE);

        _m_emitDeactivateSignal = true;
        _m_emitActivateSignal = true;
        _m_canEnable = true;
        _m_canDisable = true;
    } else if (freq == Skill::Wake) {
        setState(QSanButton::S_STATE_DISABLED);
        setStyle(QSanButton::S_STYLE_PUSH);
        _setSkillType(QSanInvokeSkillButton::S_SKILL_AWAKEN);
        _m_emitActivateSignal = false;
        _m_emitDeactivateSignal = false;
        _m_canEnable = true;
        _m_canDisable = true;
    } else if (freq == Skill::Compulsory) { // we have to set it in such way for WeiDi
        setState(QSanButton::S_STATE_UP);
        setStyle(QSanButton::S_STYLE_PUSH);
        _setSkillType(QSanInvokeSkillButton::S_SKILL_COMPULSORY);
        _m_emitActivateSignal = false;
        _m_emitDeactivateSignal = false;
        _m_canEnable = true;
        _m_canDisable = true;
    } else Q_ASSERT(false);
    setToolTip(skill->getDescription());

    Q_ASSERT((int)_m_skillType <= 5 && _m_state <= 3);
    _repaint();
}

void QSanInvokeSkillButton::_repaint()
{
    for (int i = 0; i < (int)S_NUM_BUTTON_STATES; i++) {
        _m_bgPixmap[i] = G_ROOM_SKIN.getSkillButtonPixmap((ButtonState)i, _m_skillType, _m_enumWidth);
        Q_ASSERT(!_m_bgPixmap[i].isNull());
        const IQSanComponentSkin::QSanShadowTextFont &font = G_DASHBOARD_LAYOUT.getSkillTextFont((ButtonState)i, _m_skillType, _m_enumWidth);
        QPainter painter(&_m_bgPixmap[i]);
        QString skillName = Sanguosha->translate(_m_skill->objectName());
        if (_m_enumWidth != S_WIDTH_WIDE) skillName = skillName.left(2);
        font.paintText(&painter,
            (ButtonState)i == S_STATE_DOWN ? G_DASHBOARD_LAYOUT.m_skillTextAreaDown[_m_enumWidth] :
            G_DASHBOARD_LAYOUT.m_skillTextArea[_m_enumWidth],
            Qt::AlignCenter, skillName);
    }
    setSize(_m_bgPixmap[0].size());
}

void QSanInvokeSkillButton::paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *)
{
    painter->drawPixmap(0, 0, _m_bgPixmap[(int)_m_state]);
}

QSanSkillButton *QSanInvokeSkillDock::addSkillButtonByName(const QString &skillName)
{
    Q_ASSERT(getSkillButtonByName(skillName) == NULL);
    QSanInvokeSkillButton *button = new QSanInvokeSkillButton(this);

    const Skill *skill = Sanguosha->getSkill(skillName);
    button->setSkill(skill);
    connect(button, SIGNAL(skill_activated(const Skill *)), this, SIGNAL(skill_activated(const Skill *)));
    connect(button, SIGNAL(skill_deactivated(const Skill *)), this, SIGNAL(skill_deactivated(const Skill *)));
    _m_buttons.append(button);
    update();
    return button;
}

int QSanInvokeSkillDock::width() const
{
    return _m_width;
}

int QSanInvokeSkillDock::height() const
{
    return _m_buttons.length() / 3 * G_DASHBOARD_LAYOUT.m_skillButtonsSize[0].height();
}

void QSanInvokeSkillDock::setWidth(int width)
{
    _m_width = width;
}

void QSanInvokeSkillDock::update()
{
    if (!_m_buttons.isEmpty()) {
        QList<QSanInvokeSkillButton *> regular_buttons, lordskill_buttons/*, all_buttons*/;
        foreach (QSanInvokeSkillButton *btn, _m_buttons) {
            if (!btn->getSkill()->shouldBeVisible(Self)) {
                btn->setVisible(false);
                continue;
            } else {
                btn->setVisible(true);
            }
            if (btn->getSkill()->isAttachedLordSkill())
                lordskill_buttons << btn;
            else
                regular_buttons << btn;
        }
        //all_buttons = regular_buttons + lordskill_buttons;

        int numButtons = regular_buttons.length();
        int lordskillNum = lordskill_buttons.length();
        Q_ASSERT(lordskillNum <= 6); // HuangTian, ZhiBa and XianSi
        int rows = (numButtons == 0) ? 0 : (numButtons - 1) / 3 + 1;
        int rowH = G_DASHBOARD_LAYOUT.m_skillButtonsSize[0].height();
        int *btnNum = new int[rows + lordskillNum + 2 + 1]; // we allocate one more row in case we need it.
        int remainingBtns = numButtons;
        for (int i = 0; i < rows; i++) {
            btnNum[i] = qMin(3, remainingBtns);
            remainingBtns -= 3;
        }
//        if (lordskillNum > 3) {
//            int half = lordskillNum / 2;
//            btnNum[rows] = half;
//            btnNum[rows + 1] = lordskillNum - half;
//        } else if (lordskillNum > 0) {
//            btnNum[rows] = lordskillNum;
//        }
        if (lordskillNum > 0){
            for (int k = 0; k < lordskillNum; k++){
                btnNum[rows + k] = 2;
            }
        }

        // If the buttons in rows are 3, 1, then balance them to 2, 2
        if (rows >= 2) {
            if (btnNum[rows - 1] == 1 && btnNum[rows - 2] == 3) {
                btnNum[rows - 1] = 2;
                btnNum[rows - 2] = 2;
            }
        } else if (rows == 1 && btnNum[0] == 3 && lordskillNum == 0) {
            btnNum[0] = 2;
            btnNum[1] = 1;
            rows = 2;
        }

        int m = 0;
//        int x_ls = 0;
//        if (lordskillNum > 0) x_ls++;
//        if (lordskillNum > 3) x_ls++;
//        for (int i = 0; i < rows + x_ls; i++) {
//            int rowTop = (RoomSceneInstance->m_skillButtonSank) ? (-rowH - 2 * (rows + x_ls - i - 1)) :
//                ((-rows - x_ls + i) * rowH);
//            int btnWidth = _m_width / btnNum[i];
//            for (int j = 0; j < btnNum[i]; j++) {
//                QSanInvokeSkillButton *button = all_buttons[m++];
//                button->setButtonWidth((QSanInvokeSkillButton::SkillButtonWidth)(btnNum[i] - 1));
//                button->setPos(btnWidth * j, rowTop);
//            }
//        }
        for (int i = 0; i < rows; i++) {
            int rowTop = (RoomSceneInstance->m_skillButtonSank) ? (-rowH - 2 * (rows - i - 1)) :
                ((-rows + i) * rowH);
            int btnWidth = _m_width / btnNum[i];
            for (int j = 0; j < btnNum[i]; j++) {
                QSanInvokeSkillButton *button = regular_buttons[m++];
                button->setButtonWidth((QSanInvokeSkillButton::SkillButtonWidth)(btnNum[i] - 1));
                button->setPos(btnWidth * j, rowTop);
            }
        }
        int m1 = 0;
        int rowTop1 = G_DASHBOARD_LAYOUT.m_confirmButtonArea.top() - 2.6*G_DASHBOARD_LAYOUT.m_confirmButtonArea.height();
        int rowLeft1 = G_DASHBOARD_LAYOUT.m_confirmButtonArea.left() - 2.4*G_DASHBOARD_LAYOUT.m_confirmButtonArea.width();
        int btnWidth1 = _m_width / 2;
        for (int i = 0; i < lordskillNum; i++) {
            QSanInvokeSkillButton *button = lordskill_buttons[m1++];
            button->setButtonWidth((QSanInvokeSkillButton::SkillButtonWidth)(1));
            button->setPos(rowLeft1 - btnWidth1 * i, rowTop1);
        }
        delete[] btnNum;
    }
    QGraphicsObject::update();
}

QSanInvokeSkillButton *QSanInvokeSkillDock::getSkillButtonByName(const QString &skillName) const
{
    foreach (QSanInvokeSkillButton *button, _m_buttons) {
        if (button->getSkill()->objectName() == skillName)
            return button;
    }
    return NULL;
}

