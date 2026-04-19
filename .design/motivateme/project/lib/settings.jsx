// settings.jsx — Settings screen: profile, check-ins, gentleness, appearance, data, about
// iOS grouped-inset list pattern. Reaffirms app ethos — no dark patterns, no guilt loops.

function SettingsScreen({ t, onBack }) {
  // Local state — all toggles here are fiction for the prototype
  const [name, setName] = React.useState('Jess');
  const [editingName, setEditingName] = React.useState(false);
  const [morningCheckin, setMorningCheckin] = React.useState(true);
  const [habitReminders, setHabitReminders] = React.useState(true);
  const [quietMode, setQuietMode] = React.useState(false);
  const [restDay, setRestDay] = React.useState('sunday');
  const [noStreaks, setNoStreaks] = React.useState(false);
  const [forgiveness, setForgiveness] = React.useState(3); // days
  const [appearance, setAppearance] = React.useState('auto');
  const [serifAccents, setSerifAccents] = React.useState(true);
  const [reduceMotion, setReduceMotion] = React.useState(false);
  const [backupEnabled, setBackupEnabled] = React.useState(false);

  return (
    <div style={{ height: '100%', overflow: 'auto', background: t.color.bg, paddingBottom: 100 }}>
      {/* Nav bar */}
      <div style={{
        padding: '50px 12px 0',
        display: 'flex', alignItems: 'center', position: 'sticky', top: 0, zIndex: 20,
        background: `linear-gradient(to bottom, ${t.color.bg} 80%, ${t.color.bg}00)`,
        paddingBottom: 8,
      }}>
        <button onClick={onBack} style={{
          display: 'flex', alignItems: 'center', gap: 2, padding: '8px 8px',
          border: 'none', background: 'transparent', cursor: 'pointer',
          color: t.color.primary,
          fontFamily: t.family.text, fontSize: 17, fontWeight: 500,
        }}>
          <Icon name="chevronLeft" size={20} color={t.color.primary} strokeWidth={2.4}/>
          Home
        </button>
      </div>

      {/* Large title */}
      <div style={{ padding: '0 20px 8px' }}>
        <div style={{ ...typeStyle(t.type.largeTitle, t.family),
          color: t.color.textPrimary, letterSpacing: -0.8 }}>
          Settings
        </div>
        <div style={{ ...typeStyle(t.type.subhead, t.family),
          color: t.color.textSecondary, marginTop: 2 }}>
          A handful of switches. That's all.
        </div>
      </div>

      <div style={{ padding: '14px 16px 0', display: 'flex', flexDirection: 'column', gap: 22 }}>

        {/* ── Profile ─────────────────────────────────── */}
        <Section t={t} title="Profile">
          <Row t={t} icon="person" iconBg={t.color.primary} onClick={() => setEditingName(true)}>
            <RowText t={t} label="Name" />
            <RowValue t={t} value={name}/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="heart" iconBg="#E56B8E">
            <RowText t={t} label="Pronouns" />
            <RowValue t={t} value="she/her"/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="sun" iconBg="#E89B3E" last>
            <RowText t={t} label="Rhythm" sub="When you prefer to show up"/>
            <RowValue t={t} value="Mornings"/>
            <Chevron t={t}/>
          </Row>
        </Section>

        {/* ── Check-ins & reminders ───────────────────── */}
        <Section t={t} title="Check-ins & reminders"
          footer="Notifications are gentle by default — one a day, plus the ones you set.">
          <Row t={t} icon="bell" iconBg="#D97757">
            <RowText t={t} label="Morning check-in" sub="A one-minute start to your day"/>
            <Switch t={t} value={morningCheckin} onChange={setMorningCheckin}/>
          </Row>
          <Row t={t} icon="clock" iconBg="#7AA5B8">
            <RowText t={t} label="Habit reminders" sub="For the habits you chose"/>
            <Switch t={t} value={habitReminders} onChange={setHabitReminders}/>
          </Row>
          <Row t={t} icon="moon" iconBg="#6F6BB5">
            <RowText t={t} label="Quiet hours" sub="9:30 PM — 7:00 AM"/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="leaf" iconBg="#8BA76B" last>
            <RowText t={t} label="Rest day" sub="One day off, no nudges"/>
            <RowValue t={t} value="Sundays"/>
            <Chevron t={t}/>
          </Row>
        </Section>

        {/* ── The gentle part — special treatment ───── */}
        <GentleSection t={t}
          noStreaks={noStreaks} setNoStreaks={setNoStreaks}
          forgiveness={forgiveness} setForgiveness={setForgiveness}
          quietMode={quietMode} setQuietMode={setQuietMode}/>

        {/* ── Appearance ──────────────────────────────── */}
        <Section t={t} title="Appearance">
          <Row t={t} icon="sun" iconBg="#E89B3E">
            <RowText t={t} label="Theme"/>
            <SegControl t={t} options={[
              {id:'light', label:'Light'},
              {id:'auto',  label:'Auto'},
              {id:'dark',  label:'Dark'},
            ]} value={appearance} onChange={setAppearance}/>
          </Row>
          <Row t={t} icon="edit" iconBg={t.color.primary}>
            <RowText t={t} label="Serif accents" sub="The soft italic touch on key moments"/>
            <Switch t={t} value={serifAccents} onChange={setSerifAccents}/>
          </Row>
          <Row t={t} icon="dot" iconBg="#A08BB5" last>
            <RowText t={t} label="Reduce motion"/>
            <Switch t={t} value={reduceMotion} onChange={setReduceMotion}/>
          </Row>
        </Section>

        {/* ── Your data ──────────────────────────────── */}
        <Section t={t} title="Your data"
          footer="This app stores everything on your device by default.">
          <Row t={t} icon="cloud" iconBg="#7AA5B8">
            <RowText t={t} label="Back up to iCloud" sub={backupEnabled ? 'Last backed up 2m ago' : 'Off — data stays on this phone'}/>
            <Switch t={t} value={backupEnabled} onChange={setBackupEnabled}/>
          </Row>
          <Row t={t} icon="arrowUp" iconBg="#8BA76B">
            <RowText t={t} label="Export your data" sub="As plain text or JSON"/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="arrowDown" iconBg="#9A9488">
            <RowText t={t} label="Import from another app"/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="trash" iconBg="#C45A5A" last destructive>
            <RowText t={t} label="Delete everything" sub="Fully and permanently — no 30-day recovery"/>
            <Chevron t={t}/>
          </Row>
        </Section>

        {/* ── About ──────────────────────────────────── */}
        <Section t={t} title="About">
          <Row t={t} icon="info" iconBg="#9A9488">
            <RowText t={t} label="Version"/>
            <RowValue t={t} value="1.4 · Morning Light"/>
          </Row>
          <Row t={t} icon="book" iconBg={t.color.secondary}>
            <RowText t={t} label="Help & guides"/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="heart" iconBg="#E56B8E">
            <RowText t={t} label="Say hello to the team"/>
            <Chevron t={t}/>
          </Row>
          <Row t={t} icon="leaf" iconBg="#8BA76B" last>
            <RowText t={t} label="Privacy · Terms"/>
            <Chevron t={t}/>
          </Row>
        </Section>

        {/* ── Footer affirmation ─────────────────────── */}
        <div style={{ padding: '8px 16px 40px', textAlign: 'center' }}>
          <div style={{
            fontFamily: t.family.serif || t.family.rounded,
            fontSize: 16, fontWeight: 500, lineHeight: 1.4,
            color: t.color.textSecondary, letterSpacing: -0.2,
            fontStyle: t.family.serif ? 'italic' : 'normal',
            textWrap: 'balance', maxWidth: 280, margin: '0 auto',
          }}>
            You are not a product here.<br/>Just a person, showing up.
          </div>
          <div style={{ ...typeStyle(t.type.caption1, t.family),
            color: t.color.textTertiary, marginTop: 16 }}>
            Made with care · {new Date().getFullYear()}
          </div>
        </div>
      </div>

      {/* Name edit sheet */}
      {editingName && (
        <NameEditSheet t={t} name={name} onSave={v => { setName(v); setEditingName(false); }}
          onCancel={() => setEditingName(false)}/>
      )}
    </div>
  );
}

// ── Section shell ─────────────────────────────────────────

function Section({ t, title, footer, children }) {
  return (
    <div>
      <div style={{
        ...typeStyle(t.type.footnote, t.family),
        color: t.color.textTertiary,
        textTransform: 'uppercase', letterSpacing: 0.8,
        padding: '0 16px 8px',
      }}>
        {title}
      </div>
      <div style={{
        borderRadius: 14, background: t.color.surfaceCard,
        boxShadow: t.elev.xs, overflow: 'hidden',
      }}>
        {children}
      </div>
      {footer && (
        <div style={{
          ...typeStyle(t.type.footnote, t.family),
          color: t.color.textTertiary,
          padding: '8px 16px 0', lineHeight: 1.4,
        }}>
          {footer}
        </div>
      )}
    </div>
  );
}

// ── Row ───────────────────────────────────────────────────

function Row({ t, icon, iconBg, onClick, last, destructive, children }) {
  const [pressed, setPressed] = React.useState(false);
  return (
    <div
      onClick={onClick}
      onPointerDown={() => setPressed(true)}
      onPointerUp={() => setPressed(false)}
      onPointerLeave={() => setPressed(false)}
      style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '11px 14px',
        cursor: onClick ? 'pointer' : 'default',
        borderBottom: last ? 'none' : `0.5px solid ${t.color.border}`,
        background: pressed && onClick ? `color-mix(in oklab, ${t.color.primary} 6%, transparent)` : 'transparent',
        transition: 'background 120ms',
      }}>
      {icon && (
        <div style={{
          width: 30, height: 30, borderRadius: 8, flexShrink: 0,
          background: iconBg || t.color.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name={icon} size={16} color="#fff" strokeWidth={2.2}/>
        </div>
      )}
      {React.Children.map(children, (child) =>
        React.isValidElement(child) ? React.cloneElement(child, { destructive }) : child
      )}
    </div>
  );
}

function RowText({ t, label, sub, destructive }) {
  return (
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{
        ...typeStyle(t.type.callout, t.family),
        color: destructive ? '#C45A5A' : t.color.textPrimary,
        fontWeight: 500,
      }}>
        {label}
      </div>
      {sub && (
        <div style={{
          ...typeStyle(t.type.caption1, t.family),
          color: t.color.textTertiary, marginTop: 1, lineHeight: 1.35,
        }}>
          {sub}
        </div>
      )}
    </div>
  );
}

function RowValue({ t, value }) {
  return (
    <div style={{
      ...typeStyle(t.type.callout, t.family),
      color: t.color.textTertiary, flexShrink: 0,
    }}>
      {value}
    </div>
  );
}

function Chevron({ t }) {
  return (
    <div style={{ flexShrink: 0, opacity: 0.35, marginLeft: 4 }}>
      <Icon name="chevronRight" size={14} color={t.color.textSecondary} strokeWidth={2}/>
    </div>
  );
}

// ── Switch (iOS style) ────────────────────────────────────

function Switch({ t, value, onChange }) {
  return (
    <button
      onClick={(e) => { e.stopPropagation(); onChange(!value); }}
      style={{
        width: 51, height: 31, borderRadius: 999, border: 'none', cursor: 'pointer',
        background: value ? '#34C759' : `color-mix(in oklab, ${t.color.textPrimary} 15%, ${t.color.surfaceCard})`,
        position: 'relative', flexShrink: 0, padding: 0,
        transition: 'background 220ms cubic-bezier(0.34, 1.2, 0.64, 1)',
      }}>
      <div style={{
        position: 'absolute', top: 2, left: value ? 22 : 2,
        width: 27, height: 27, borderRadius: '50%',
        background: '#fff',
        boxShadow: '0 3px 8px rgba(0,0,0,0.15), 0 2px 2px rgba(0,0,0,0.1)',
        transition: 'left 220ms cubic-bezier(0.34, 1.4, 0.64, 1)',
      }}/>
    </button>
  );
}

// ── Segmented control ─────────────────────────────────────

function SegControl({ t, options, value, onChange }) {
  return (
    <div style={{
      display: 'flex', padding: 2, borderRadius: 9,
      background: `color-mix(in oklab, ${t.color.textPrimary} 8%, transparent)`,
      flexShrink: 0,
    }}>
      {options.map(opt => {
        const active = value === opt.id;
        return (
          <button key={opt.id} onClick={(e) => { e.stopPropagation(); onChange(opt.id); }}
            style={{
              padding: '5px 11px', borderRadius: 7, border: 'none', cursor: 'pointer',
              background: active ? t.color.surfaceCard : 'transparent',
              color: t.color.textPrimary,
              fontFamily: t.family.rounded, fontSize: 13, fontWeight: active ? 600 : 500,
              boxShadow: active ? '0 2px 6px rgba(0,0,0,0.08)' : 'none',
              transition: 'all 180ms',
            }}>
            {opt.label}
          </button>
        );
      })}
    </div>
  );
}

// ── The Gentle Part (custom styled section) ──────────────

function GentleSection({ t, noStreaks, setNoStreaks, forgiveness, setForgiveness, quietMode, setQuietMode }) {
  return (
    <div>
      <div style={{
        display: 'flex', alignItems: 'baseline', gap: 8,
        padding: '0 16px 8px',
      }}>
        <div style={{
          ...typeStyle(t.type.footnote, t.family),
          color: t.color.textTertiary,
          textTransform: 'uppercase', letterSpacing: 0.8,
        }}>
          The gentle part
        </div>
        <div style={{ width: 3, height: 3, borderRadius: 2, background: t.color.secondary, marginBottom: 2 }}/>
        <div style={{
          ...typeStyle(t.type.caption2, t.family),
          color: t.color.secondary, fontStyle: 'italic',
        }}>
          the ethos, in switches
        </div>
      </div>

      <div style={{
        borderRadius: 18, overflow: 'hidden',
        background: `linear-gradient(180deg, ${t.color.secondaryTint} 0%, ${t.color.surfaceCard} 60%)`,
        border: `0.5px solid ${t.color.border}`,
      }}>
        {/* Quote */}
        <div style={{ padding: '16px 18px 14px', display: 'flex', gap: 10 }}>
          <div style={{
            fontFamily: t.family.serif || t.family.rounded,
            fontSize: 36, lineHeight: 0.8, color: t.color.secondary,
            fontStyle: 'italic', flexShrink: 0,
          }}>
            "
          </div>
          <div style={{
            fontFamily: t.family.serif || t.family.rounded,
            fontSize: 15, lineHeight: 1.4,
            color: t.color.textPrimary,
            fontStyle: t.family.serif ? 'italic' : 'normal',
            letterSpacing: -0.1,
          }}>
            Missing days is part of life, not a failure. These switches decide how we respond.
          </div>
        </div>

        {/* Switches */}
        <div style={{ padding: '0 4px 4px' }}>
          <Row t={t} icon="flame" iconBg="#E89B3E">
            <RowText t={t}
              label="Hide streak numbers"
              sub="You'll still see progress — without the counter"/>
            <Switch t={t} value={noStreaks} onChange={setNoStreaks}/>
          </Row>

          {/* Forgiveness window */}
          <div style={{
            padding: '14px 14px',
            borderTop: `0.5px solid ${t.color.border}`,
            display: 'flex', flexDirection: 'column', gap: 10,
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 30, height: 30, borderRadius: 8, flexShrink: 0,
                background: '#8BA76B',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                <Icon name="leaf" size={16} color="#fff"/>
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ ...typeStyle(t.type.callout, t.family),
                  color: t.color.textPrimary, fontWeight: 500 }}>
                  Forgiveness window
                </div>
                <div style={{ ...typeStyle(t.type.caption1, t.family),
                  color: t.color.textTertiary, marginTop: 1 }}>
                  Days you can miss before anything changes
                </div>
              </div>
              <div style={{
                padding: '3px 10px', borderRadius: 999,
                background: t.color.primaryTint,
                ...typeStyle(t.type.caption1, t.family),
                color: t.color.primary, fontWeight: 700,
              }}>
                {forgiveness} {forgiveness === 1 ? 'day' : 'days'}
              </div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '0 2px' }}>
              <input type="range" min="0" max="7" step="1"
                value={forgiveness} onChange={e => setForgiveness(+e.target.value)}
                style={{ flex: 1, accentColor: t.color.primary }}/>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between',
              ...typeStyle(t.type.caption2, t.family), color: t.color.textTertiary }}>
              <span>Strict</span>
              <span>Balanced</span>
              <span>Forgiving</span>
            </div>
          </div>

          {/* Quiet mode */}
          <div style={{ borderTop: `0.5px solid ${t.color.border}` }}>
            <Row t={t} icon="moon" iconBg="#6F6BB5" last>
              <RowText t={t}
                label="Quiet mode"
                sub="Dim stats, numbers, and comparisons for a while"/>
              <Switch t={t} value={quietMode} onChange={setQuietMode}/>
            </Row>
          </div>
        </div>
      </div>
      <div style={{
        ...typeStyle(t.type.footnote, t.family),
        color: t.color.textTertiary,
        padding: '8px 16px 0', lineHeight: 1.4, fontStyle: 'italic',
      }}>
        These are the ones we're most proud of.
      </div>
    </div>
  );
}

// ── Name edit sheet ───────────────────────────────────────

function NameEditSheet({ t, name, onSave, onCancel }) {
  const [value, setValue] = React.useState(name);
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 40,
      background: 'rgba(20, 15, 10, 0.35)',
      display: 'flex', alignItems: 'flex-end',
      animation: 'mmFade 200ms ease-out',
    }} onClick={onCancel}>
      <div onClick={e => e.stopPropagation()}
        style={{
          width: '100%', background: t.color.bg,
          borderTopLeftRadius: 20, borderTopRightRadius: 20,
          padding: '14px 20px 32px',
          animation: 'mmSlideUp 280ms cubic-bezier(0.34, 1.2, 0.64, 1)',
        }}>
        <div style={{
          width: 40, height: 4, borderRadius: 2, margin: '4px auto 18px',
          background: t.color.border,
        }}/>
        <div style={{ ...typeStyle(t.type.title3, t.family),
          color: t.color.textPrimary, fontWeight: 600 }}>
          Your name
        </div>
        <div style={{ ...typeStyle(t.type.footnote, t.family),
          color: t.color.textSecondary, marginTop: 2 }}>
          However you'd like to be greeted.
        </div>
        <div style={{
          marginTop: 16, padding: '14px 16px', borderRadius: 14,
          background: t.color.surfaceCard, boxShadow: t.elev.xs,
        }}>
          <input autoFocus
            value={value} onChange={e => setValue(e.target.value)}
            style={{
              width: '100%', border: 'none', outline: 'none', background: 'transparent',
              fontFamily: t.family.rounded, fontSize: 18, fontWeight: 500,
              color: t.color.textPrimary,
            }}/>
        </div>
        <button onClick={() => onSave(value || name)}
          style={{
            width: '100%', marginTop: 16, padding: '14px',
            borderRadius: t.radius.pill, border: 'none', cursor: 'pointer',
            background: t.color.primary, color: t.color.onPrimary,
            fontFamily: t.family.rounded, fontSize: 16, fontWeight: 700,
          }}>
          Save
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { SettingsScreen });
