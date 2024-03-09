class CloudStroageException implements Exception {
  const CloudStroageException();
}

// C in CRUD
class CouldNotCreateNoteException extends CloudStroageException {}

// R in CRUD
class CouldNotGetAllNoteException extends CloudStroageException {}

// U in CRUD
class CouldNotUpdateNoteException extends CloudStroageException {}

// D in CRUD
class CouldNotDeleteNoteException extends CloudStroageException {}
