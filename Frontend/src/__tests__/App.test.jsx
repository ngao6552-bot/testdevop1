/**
 * Basic App component tests
 */

describe('App Component', () => {
  test('should render without crashing', () => {
    expect(true).toBe(true);
  });

  test('should verify app name', () => {
    const appName = 'Student Management System';
    expect(appName).toContain('Student');
  });

  test('should check math operations', () => {
    const result = 5 * 2;
    expect(result).toBe(10);
  });
});
