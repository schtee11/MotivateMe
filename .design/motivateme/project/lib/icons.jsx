// icons.jsx — SF-Symbols-adjacent iconography (single stroke weight, rounded joins)
// Using simple geometric icons at 1.8 stroke, bicone linecap

const Icon = ({ name, size = 22, color = 'currentColor', filled = false, strokeWidth = 1.8 }) => {
  const common = {
    width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
    stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round',
  };
  const paths = {
    flame: filled
      ? <path d="M12 2c1 3 4 4 4 8a4 4 0 01-8 0c0-2 1-3 1-5-1.5 1-3 3-3 6a6 6 0 0012 0c0-5-4-6-6-9z" fill={color} stroke="none"/>
      : <path d="M12 3c.5 2.5 3.5 3.5 3.5 7a3.5 3.5 0 01-7 0c0-1.5.5-2.5.5-4-1 .8-2.5 2.5-2.5 5.5a5.5 5.5 0 0011 0c0-4.5-3.5-5.5-5.5-8.5z"/>,
    check: <path d="M5 12.5l4.5 4.5L19 7.5"/>,
    checkCircle: filled
      ? <g><circle cx="12" cy="12" r="10" fill={color} stroke="none"/><path d="M7.5 12.5l3 3 6-6.5" stroke="#fff" strokeWidth="2.2"/></g>
      : <g><circle cx="12" cy="12" r="9.2"/><path d="M7.5 12.5l3 3 6-6.5"/></g>,
    circle: <circle cx="12" cy="12" r="9.2"/>,
    plus: <g><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></g>,
    close: <g><line x1="6" y1="6" x2="18" y2="18"/><line x1="18" y1="6" x2="6" y2="18"/></g>,
    chevronRight: <path d="M9 5l7 7-7 7"/>,
    chevronLeft: <path d="M15 5l-7 7 7 7"/>,
    chevronDown: <path d="M5 9l7 7 7-7"/>,
    sun: <g><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5.6 5.6L4.2 4.2M19.8 19.8l-1.4-1.4M5.6 18.4l-1.4 1.4M19.8 4.2l-1.4 1.4"/></g>,
    moon: <path d="M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z"/>,
    leaf: <g><path d="M20 4c0 9-6 14-13 14-2 0-3-1-3-1s0-13 9-15c4-1 7 0 7 2z"/><path d="M4 20c3-5 7-9 13-14"/></g>,
    heart: filled
      ? <path d="M12 21s-8-5.5-8-11.5a4.5 4.5 0 018-3 4.5 4.5 0 018 3c0 6-8 11.5-8 11.5z" fill={color} stroke="none"/>
      : <path d="M12 20s-7-4.8-7-10.5a4 4 0 017-2.6 4 4 0 017 2.6c0 5.7-7 10.5-7 10.5z"/>,
    dumbbell: <g><rect x="1.5" y="9" width="3" height="6" rx="1"/><rect x="19.5" y="9" width="3" height="6" rx="1"/><rect x="4.5" y="10.5" width="2" height="3"/><rect x="17.5" y="10.5" width="2" height="3"/><line x1="6.5" y1="12" x2="17.5" y2="12"/></g>,
    figure: <g><circle cx="14" cy="4.5" r="2"/><path d="M14 7c-2 0-3.5 1.5-4 3l-1.5 5 3 1 1-3.5 2 4.5v4h2v-4.5l-1.5-5.5 3 1.5 2-3c-1-1-2.5-2-4-2z" fill={color} stroke="none"/></g>,
    chart: <g><path d="M3 20V4M3 20h18"/><path d="M7 16l4-5 3 2 5-7"/></g>,
    clock: <g><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3.5 2"/></g>,
    book: <path d="M4 4h6a3 3 0 013 3v13a2 2 0 00-2-2H4V4zm16 0h-6a3 3 0 00-3 3v13a2 2 0 012-2h7V4z"/>,
    bell: <g><path d="M6 9a6 6 0 0112 0c0 5 2 6 2 6H4s2-1 2-6z"/><path d="M10 20a2 2 0 004 0"/></g>,
    sparkles: <g><path d="M12 3l1.5 4L17 8l-3.5 1L12 13l-1.5-4L7 8l3.5-1z"/><path d="M19 14l.8 2 2 .8-2 .8-.8 2-.8-2-2-.8 2-.8z"/><path d="M5 16l.6 1.5 1.4.5-1.4.5L5 20l-.6-1.5L3 18l1.4-.5z"/></g>,
    settings: <g><circle cx="12" cy="12" r="3"/><path d="M12 2l1 2.5 2.5-.5.5 2.5 2.5 1-.5 2.5 2 1.5-2 1.5.5 2.5-2.5 1-.5 2.5-2.5-.5L12 22l-1-2.5-2.5.5-.5-2.5-2.5-1 .5-2.5-2-1.5 2-1.5-.5-2.5 2.5-1 .5-2.5 2.5.5z"/></g>,
    person: <g><circle cx="12" cy="7.5" r="3.5"/><path d="M4.5 20c.5-4 3.5-6.5 7.5-6.5s7 2.5 7.5 6.5"/></g>,
    calendar: <g><rect x="3" y="5" width="18" height="16" rx="2.5"/><path d="M3 10h18M8 3v4M16 3v4"/></g>,
    arrowRight: <path d="M5 12h14M13 6l6 6-6 6"/>,
    dots: <g><circle cx="5" cy="12" r="1.5" fill={color}/><circle cx="12" cy="12" r="1.5" fill={color}/><circle cx="19" cy="12" r="1.5" fill={color}/></g>,
    mic: <g><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0014 0M12 18v3"/></g>,
    pencil: <path d="M4 20l1-4L15 6l3 3L8 19l-4 1z"/>,
    wave: <path d="M3 12c2-4 4-4 6 0s4 4 6 0 4-4 6 0"/>,
    trophy: <g><path d="M7 4h10v4a5 5 0 01-10 0V4z"/><path d="M7 6H4v2a3 3 0 003 3M17 6h3v2a3 3 0 01-3 3"/><path d="M10 13v3h4v-3M8 20h8"/></g>,
    timer: <g><circle cx="12" cy="13" r="8"/><path d="M12 13V9M10 2h4"/></g>,
    filter: <path d="M3 5h18l-7 9v5l-4 2v-7z"/>,
    search: <g><circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/></g>,
    play: <path d="M7 5l13 7-13 7V5z" fill={color} stroke="none"/>,
    cloud: <path d="M7 18a4 4 0 010-8 5 5 0 019.6-1.5A4 4 0 0117 18H7z"/>,
    arrowUp: <path d="M12 19V5M6 11l6-6 6 6"/>,
    arrowDown: <path d="M12 5v14M6 13l6 6 6-6"/>,
    trash: <g><path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"/><path d="M10 11v6M14 11v6"/></g>,
    info: <g><circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8v.5"/></g>,
    edit: <g><path d="M4 20l1-4L15 6l3 3L8 19l-4 1z"/><path d="M13 8l3 3"/></g>,
    dot: <circle cx="12" cy="12" r="4" fill={color} stroke="none"/>,
  };
  return <svg {...common}>{paths[name] || paths.circle}</svg>;
};

window.Icon = Icon;
