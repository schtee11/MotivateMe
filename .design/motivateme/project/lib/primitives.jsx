// primitives.jsx — iOS primitives styled to the MotivateMe system
// Buttons, TextField, Toggle, Segmented, TabBar, NavBar, Sheet

function MMTextField({ t, label, value, onChange, placeholder, icon }) {
  return (
    <div>
      {label && <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginBottom: 6, paddingLeft: 4 }}>{label}</div>}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10, padding: '0 14px',
        height: 48, borderRadius: 14, background: t.color.surfaceInput,
      }}>
        {icon && <Icon name={icon} size={18} color={t.color.textTertiary}/>}
        <input value={value} onChange={e => onChange?.(e.target.value)} placeholder={placeholder}
          style={{
            flex: 1, border: 'none', outline: 'none', background: 'transparent',
            fontFamily: t.family.text, fontSize: 17, color: t.color.textPrimary,
          }}/>
      </div>
    </div>
  );
}

function MMToggle({ t, on, onChange }) {
  return (
    <button onClick={() => onChange?.(!on)} style={{
      width: 52, height: 32, borderRadius: 9999, border: 'none', padding: 2,
      background: on ? t.color.primary : t.color.surfaceInput,
      display: 'flex', alignItems: 'center', cursor: 'pointer',
      transition: 'background 220ms', boxShadow: 'inset 0 0 0 0.5px rgba(0,0,0,0.04)',
    }}>
      <div style={{
        width: 28, height: 28, borderRadius: '50%', background: '#fff',
        transform: on ? 'translateX(20px)' : 'translateX(0)',
        transition: 'transform 260ms cubic-bezier(0.34, 1.2, 0.64, 1)',
        boxShadow: '0 2px 4px rgba(0,0,0,0.15), 0 0 0 0.5px rgba(0,0,0,0.04)',
      }}/>
    </button>
  );
}

function MMSegmented({ t, options, value, onChange }) {
  return (
    <div style={{
      display: 'flex', padding: 2, borderRadius: 10, background: t.color.surfaceInput,
      position: 'relative',
    }}>
      {options.map(o => {
        const active = o.value === value;
        return (
          <button key={o.value} onClick={() => onChange?.(o.value)} style={{
            flex: 1, height: 30, borderRadius: 8, border: 'none', cursor: 'pointer',
            background: active ? t.color.surface : 'transparent',
            boxShadow: active ? t.elev.xs : 'none',
            fontFamily: t.family.text, fontSize: 13, fontWeight: active ? 600 : 500,
            color: active ? t.color.textPrimary : t.color.textSecondary,
            transition: 'all 180ms',
          }}>{o.label}</button>
        );
      })}
    </div>
  );
}

function MMTabBar({ t, items, active, onChange }) {
  return (
    <div style={{
      display: 'flex', padding: '8px 0 0',
      background: t.color.surface,
      borderTop: `0.5px solid ${t.color.separator}`,
      backdropFilter: 'blur(24px) saturate(180%)',
    }}>
      {items.map(it => {
        const on = it.key === active;
        return (
          <button key={it.key} onClick={() => onChange?.(it.key)} style={{
            flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            padding: '6px 0 2px', border: 'none', background: 'transparent', cursor: 'pointer',
          }}>
            <Icon name={it.icon} size={26} color={on ? t.color.primary : t.color.textTertiary}
              strokeWidth={on ? 2 : 1.6} filled={on}/>
            <span style={{ fontFamily: t.family.text, fontSize: 10, fontWeight: 500,
              color: on ? t.color.primary : t.color.textTertiary }}>{it.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// Nav bar styled in-system (distinct from the starter glass pill version — this one matches tokens)
function MMNavBar({ t, title, large = true, leading, trailing, subtitle }) {
  return (
    <div style={{ padding: large ? '52px 20px 8px' : '54px 16px 10px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, minHeight: 34 }}>
        <div style={{ minWidth: 40 }}>{leading}</div>
        <div style={{ flex: 1, textAlign: large ? 'left' : 'center' }}>
          {!large && (
            <span style={{ ...typeStyle(t.type.headline, t.family), color: t.color.textPrimary }}>{title}</span>
          )}
        </div>
        <div style={{ minWidth: 40, display: 'flex', justifyContent: 'flex-end' }}>{trailing}</div>
      </div>
      {large && (
        <>
          <div style={{ ...typeStyle(t.type.largeTitle, t.family), color: t.color.textPrimary, marginTop: 2 }}>
            {title}
          </div>
          {subtitle && (
            <div style={{ ...typeStyle(t.type.subhead, t.family), color: t.color.textSecondary, marginTop: 2 }}>
              {subtitle}
            </div>
          )}
        </>
      )}
    </div>
  );
}

// Bottom sheet with grabber
function MMSheet({ t, children, onClose, height = '80%' }) {
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 100 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.25)',
        animation: 'mmFade 220ms ease' }}/>
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0, height,
        background: t.color.surfaceModal,
        borderTopLeftRadius: t.radius.sheet, borderTopRightRadius: t.radius.sheet,
        boxShadow: t.elev.xl, display: 'flex', flexDirection: 'column',
        animation: 'mmSlideUp 340ms cubic-bezier(0.34, 1.2, 0.64, 1)',
      }}>
        <div style={{ padding: '6px 0', display: 'flex', justifyContent: 'center', flexShrink: 0 }}>
          <div style={{ width: 36, height: 5, borderRadius: 9999, background: t.color.separatorStrong }}/>
        </div>
        <div style={{ flex: 1, overflow: 'auto' }}>{children}</div>
      </div>
    </div>
  );
}

// List row in MotivateMe style (warmer than the glass starter)
function MMRow({ t, icon, iconBg, title, detail, value, chevron = true, isLast = false, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px',
      minHeight: 52, cursor: onClick ? 'pointer' : 'default', position: 'relative',
    }}>
      {icon && (
        <div style={{ width: 30, height: 30, borderRadius: 8, background: iconBg || t.color.primaryMuted,
          display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name={icon} size={17} color={t.color.primary}/>
        </div>
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...typeStyle(t.type.body, t.family), color: t.color.textPrimary }}>{title}</div>
        {detail && <div style={{ ...typeStyle(t.type.footnote, t.family), color: t.color.textSecondary, marginTop: 1 }}>{detail}</div>}
      </div>
      {value && <span style={{ ...typeStyle(t.type.body, t.family), color: t.color.textSecondary }}>{value}</span>}
      {chevron && <Icon name="chevronRight" size={14} color={t.color.textTertiary} strokeWidth={2.2}/>}
      {!isLast && <div style={{ position: 'absolute', left: icon ? 58 : 16, right: 0, bottom: 0, height: 0.5, background: t.color.separator }}/>}
    </div>
  );
}

function MMCard({ t, children, padding = 16, style = {} }) {
  return (
    <div style={{
      background: t.color.surfaceCard, borderRadius: t.radius.card,
      padding, boxShadow: t.elev.sm, ...style,
    }}>{children}</div>
  );
}

Object.assign(window, { MMTextField, MMToggle, MMSegmented, MMTabBar, MMNavBar, MMSheet, MMRow, MMCard });
