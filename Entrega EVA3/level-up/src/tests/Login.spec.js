import { 
  validarEmailVacio, 
  validarFormatoEmail, 
  validarPasswordVacio, 
  validarCredenciales 
} from '../utils/validaciones';

describe('Tests del Componente Login', function() {
  beforeEach(function() {
    localStorage.clear();
  });

  it('valida mail vacío', function() {
    var formData = {
      email: '',
      password: 'test123'
    };
    expect(validarEmailVacio(formData.email)).toBe(false);
  });

  it('valida formato de mail', function() {
    var email = 'invalid-email';
    expect(validarFormatoEmail(email)).toBe(false);
    
    email = 'valid@email.com';
    expect(validarFormatoEmail(email)).toBe(true);
  });

  it('valida contraseña vacía', function() {
    var formData = {
      email: 'test@email.com',
      password: ''
    };
    expect(validarPasswordVacio(formData.password)).toBe(false);
  });

  it('valida credenciales de usuario', function() {
    var usuarios = [
      {
        correo: 'test@email.com',
        password: 'test123'
      }
    ];
    localStorage.setItem('usuarios', JSON.stringify(usuarios));

    var credentials = {
      email: 'test@email.com',
      password: 'test123'
    };
    expect(validarCredenciales(credentials)).toBe(true);

    credentials.password = 'wrong';
    expect(validarCredenciales(credentials)).toBe(false);
  });
});