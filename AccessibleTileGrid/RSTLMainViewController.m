//
//  RSTLMainViewController.m
//
//  Created by Doug Russell
//  Copyright (c) 2012 Doug Russell. All rights reserved.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "RSTLMainViewController.h"
#import "RSTLContainerGLKView.h"
#import "RSTLAccessibleTileGrid.h"
#import "RSTLAccessibleCurrentWord.h"

// Bunch of OpenGL boiler plate

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface RSTLMainViewController ()
{
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

// Start accessibility code

@interface RSTLMainViewController () // Accessibility properties
@property (nonatomic) id observer;
@property (nonatomic) BOOL isVoiceOverRunning;
@property (nonatomic) RSTLAccessibleTileGrid *tileGrid;
@property (nonatomic) RSTLAccessibleCurrentWord *currentWord;
@end

@implementation RSTLMainViewController

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		__weak RSTLMainViewController *wSelf = self;
		self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIAccessibilityVoiceOverStatusChanged object:nil queue:nil usingBlock:^(NSNotification *note) {
			wSelf.isVoiceOverRunning = UIAccessibilityIsVoiceOverRunning();
		}];
		_isVoiceOverRunning = UIAccessibilityIsVoiceOverRunning();
	}
	return self;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	RSTLContainerGLKView *view = (RSTLContainerGLKView *)[self view];
	RSTLAccessibleTileGrid *tileGrid = self.tileGrid;
	RSTLAccessibleCurrentWord *currentWord = self.currentWord;
	CGRect bounds = view.bounds;
	
	CGFloat gridSide = 400.0f;
	CGFloat gridX = bounds.size.width / 2.0f - gridSide / 2.0f;
	CGFloat gridY = bounds.size.height / 2.0f - gridSide / 2.0f;
	CGRect rect = CGRectMake(gridX, gridY, gridSide, gridSide);
	tileGrid.frameRelativeToContainer = rect;
	[tileGrid layoutTiles];
	
	rect.origin.y -= 100.0f;
	rect.size.height = 80.0f;
	currentWord.frameRelativeToContainer = rect;
	[currentWord layoutTiles];
}

- (void)loadView
{
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if (!self.context)
        NSLog(@"Failed to create ES context");
	RSTLContainerGLKView *view = [[RSTLContainerGLKView alloc] initWithFrame:CGRectZero context:self.context];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	self.view = view;
	
	// In a real implementation this would need to handle a changing number of columns
	RSTLAccessibleCurrentWord *currentWord = [[RSTLAccessibleCurrentWord alloc] initWithRows:1 columns:5 accessibilityContainer:view];
	[view addAccessibilityElement:currentWord];
	self.currentWord = currentWord;
	
	RSTLAccessibleTileGrid *tileGrid = [[RSTLAccessibleTileGrid alloc] initWithRows:5 columns:5 accessibilityContainer:view];
	[view addAccessibilityElement:tileGrid];
	self.tileGrid = tileGrid;
}

- (void)loadTileData
{
	// In order to avoid writing real game logic I just load the tile states out of a plist. Clearly this is just demo code.
	NSArray *tileArray = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Tiles" withExtension:@"plist"]];
	RSTLAccessibleTileGrid *tileGrid = self.tileGrid;
	for (NSUInteger row = 0; row < self.tileGrid.rows; row++)
	{
		for (NSUInteger column = 0; column < tileGrid.columns; column++)
		{
			NSDictionary *tileDictionary = tileArray[tileGrid.columns * row + column];
			ASTilePosition position = (ASTilePosition){ row, column };
			[tileGrid setCharacter:tileDictionary[@"character"] atPosition:position];
			[tileGrid setIsBlockedIn:[tileDictionary[@"isBlockedIn"] boolValue] atPosition:position];
			[tileGrid setOwner:tileDictionary[@"owner"] atPosition:position];
		}
	}
	
	NSArray *wordArray = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Words" withExtension:@"plist"]];
	RSTLAccessibleCurrentWord *currentWord = self.currentWord;
	for (NSUInteger column = 0; column < currentWord.columns; column++)
	{
		NSDictionary *tileDictionary = wordArray[column];
		ASTilePosition position = (ASTilePosition){ 0, column };
		[currentWord setCharacter:tileDictionary[@"character"] atPosition:position];
		[currentWord setIsBlockedIn:[tileDictionary[@"isBlockedIn"] boolValue] atPosition:position];
		[currentWord setOwner:tileDictionary[@"owner"] atPosition:position];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// You likely want to handle touches differently in VO mode since things like drags aren't very accessibility friendly
	if (self.isVoiceOverRunning)
	{
		if ([touches count] == 1)
		{
			UITouch *touch = [touches anyObject];
			if ([touch tapCount] == 1)
			{
				CGPoint point = [touch locationInView:self.view];
				if (CGRectContainsPoint(self.tileGrid.frameRelativeToContainer, point))
				{
					// Adjust point to tile grids coordinates
					point.x -= self.tileGrid.frameRelativeToContainer.origin.x;
					point.y -= self.tileGrid.frameRelativeToContainer.origin.y;
					[self.tileGrid playTileAtPoint:point];
					// In a real game playing this tile would mean updating the current word,
					// at which point you could do useful things like post a screen changed
					// notification that gives the tile that has been moved to the current
					// word container focus.
				}
				else if (CGRectContainsPoint(self.currentWord.frameRelativeToContainer, point))
				{
					// Adjust point to tile grids coordinates
					point.x -= self.tileGrid.frameRelativeToContainer.origin.x;
					point.y -= self.tileGrid.frameRelativeToContainer.origin.y;
					[self.currentWord playTileAtPoint:point];
				}
			}
		}
	}
	[super touchesEnded:touches withEvent:event];
}

// End accessibility code

#pragma mark - Boiler plate from the open gl game template

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupGL];
	[self loadTileData];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self.observer];
	
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
	{
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	
    if ([self isViewLoaded] && ([[self view] window] == nil))
	{
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context)
		{
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
	
    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program)
	{
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
	{
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
	{
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program])
	{
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader)
		{
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
		{
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program)
		{
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader)
	{
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
	{
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
	{
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
	{
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
	{
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
	{
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
	{
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
	{
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
	{
        return NO;
    }
    
    return YES;
}

@end
