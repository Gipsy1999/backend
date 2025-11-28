import { 
  validarRUN, 
  validarNombreLength, 
  validarApellidosLength, 
  validarEmailDuplicado 
} from '../utils/validaciones';

describe('Tests del Componente Registro', function() {
  beforeEach(function() {
    localStorage.clear();
  });

  it('valida formato de RUN', function() {
    expect(validarRUN('123456789')).toBe(true);
    expect(validarRUN('12345')).toBe(false);
  });

  it('valida longitud del nombre', function() {
    var nombre = 'a'.repeat(51);
    expect(validarNombreLength(nombre)).toBe(false);
    
    nombre = 'Juan';
    expect(validarNombreLength(nombre)).toBe(true);
  });

  it('valida longitud de apellidos', function() {
    var apellidos = 'a'.repeat(101);
    expect(validarApellidosLength(apellidos)).toBe(false);
    
    apellidos = 'Pérez González';
    expect(validarApellidosLength(apellidos)).toBe(true);
  });

  it('previene registro de mail duplicado', function() {
    var usuarios = [
      {
        correo: 'existing@email.com',
        nombre: 'Existing User'
      }
    ];
    localStorage.setItem('usuarios', JSON.stringify(usuarios));

    expect(validarEmailDuplicado('existing@email.com')).toBe(false);
    expect(validarEmailDuplicado('new@email.com')).toBe(true);
  });
});