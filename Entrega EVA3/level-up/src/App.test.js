/* eslint-disable import/first */
import { render, screen } from '@testing-library/react';
import React from 'react';

jest.mock('react-router-dom');

import App from './App';

describe('Componente App', () => {
  test('renderiza la aplicación sin errores', () => {
    render(<App />);
    const router = screen.getByTestId('router');
    expect(router).toBeInTheDocument();
  });

  test('renderiza el header con logo', () => {
    render(<App />);
    const logoElements = screen.getAllByText(/LEVEL-UP GAMER/i);
    expect(logoElements[0]).toBeInTheDocument();
  });
});
