Class {
	#name : #TFCallback,
	#superclass : #FFIExternalReference,
	#instVars : [
		'callbackData',
		'parameterHandlers',
		'returnTypeHandler',
		'runner',
		'parameterTypes',
		'returnType',
		'frontendCallback'
	],
	#category : #'ThreadedFFI-Callbacks'
}

{ #category : #finalization }
TFCallback class >> finalizeResourceData: aCallbackDataHandler [

	self primUnregister: aCallbackDataHandler.
	aCallbackDataHandler beNull
]

{ #category : #'instance creation' }
TFCallback class >> forCallback: aCallback parameters: parameterTypes returnType: returnType runner: aRunner [

	^ self new
		frontendCallback: aCallback;
		parameterTypes: parameterTypes;
		returnType: returnType;
		runner: aRunner;
		autoRelease;
		register;
		yourself
]

{ #category : #'private primitives' }
TFCallback class >> primUnregister: callbackHandle [
	<primitive: 'primitiveUnregisterCallback' module: 'PThreadedPlugin'>

	^ self primitiveFailed
]

{ #category : #accessing }
TFCallback >> beNull [

	self setHandle: ExternalAddress null

]

{ #category : #accessing }
TFCallback >> callbackData [
	^ callbackData
]

{ #category : #accessing }
TFCallback >> callbackData: anObject [
	callbackData := anObject
]

{ #category : #accessing }
TFCallback >> frontendCallback [

	^ frontendCallback
]

{ #category : #accessing }
TFCallback >> frontendCallback: anObject [
	frontendCallback := anObject
]

{ #category : #initialization }
TFCallback >> initialize [

	super initialize.
	callbackData := ExternalAddress new.
	parameterHandlers := #()
]

{ #category : #accessing }
TFCallback >> parameterTypes [
	^ parameterTypes
]

{ #category : #accessing }
TFCallback >> parameterTypes: anObject [
	parameterTypes := anObject
]

{ #category : #registering }
TFCallback >> register [
	
	handle isNull ifFalse: [ ^ self error: 'Callback already registered' ].
	
	self validateTypes.
	self runner ensureInitialized.
	self registerCallback.
	TFCallbackQueue uniqueInstance registerCallback: self.
]

{ #category : #registering }
TFCallback >> registerCallback [

	<primitive: 'primitiveRegisterCallback' module: 'PThreadedPlugin'>
	^ self primitiveFailed 
]

{ #category : #accessing }
TFCallback >> resourceData [

	^ self callbackData.

]

{ #category : #accessing }
TFCallback >> returnType [
	^ returnType
]

{ #category : #accessing }
TFCallback >> returnType: anObject [
	returnType := anObject
]

{ #category : #accessing }
TFCallback >> runner [
	^ runner
]

{ #category : #accessing }
TFCallback >> runner: anObject [
	runner := anObject
]

{ #category : #accessing }
TFCallback >> thunk [
	^ self getHandle 
]

{ #category : #'private operations' }
TFCallback >> validateTypes [

	parameterTypes do: [ :each | each validate ].
	returnType validate.

	parameterHandlers := parameterTypes collect: [ :e | e basicType ] as: Array.
	returnTypeHandler := returnType basicType.
]
