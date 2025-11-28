const React = require('react');

module.exports = {
  BrowserRouter: ({ children }) => <div data-testid="router">{children}</div>,
  Routes: ({ children }) => <div>{children}</div>,
  Route: ({ element }) => <div>{element}</div>,
  Link: ({ children, to, ...props }) => <a href={to} {...props}>{children}</a>,
  Navigate: ({ to }) => <div data-testid="navigate" data-to={to}>Redirecting to {to}</div>,
  useNavigate: () => jest.fn(),
  useParams: () => ({ codigo: 'TEST001' }),
  useLocation: () => ({ pathname: '/' })
};
