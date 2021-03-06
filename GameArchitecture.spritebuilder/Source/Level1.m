//
//  Level1.m
//  GameArchitecture
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "Level1.h"
#import "WinPopup.h"
#import "CCActionFollow+CurrentOffset.h"
#define CP_ALLOW_PRIVATE_ACCESS 1
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Level1 {
  CCSprite *_character;
  CCPhysicsNode *_physicsNode;
  BOOL _jumped;
}

- (void)didLoadFromCCB {
  _physicsNode.collisionDelegate = self;
}

- (void)onEnter {
  [super onEnter];

  CCActionFollow *follow = [CCActionFollow actionWithTarget:_character worldBoundary:_physicsNode.boundingBox];
  _physicsNode.position = [follow currentOffset];
  [_physicsNode runAction:follow];
}

- (void)onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  
  self.userInteractionEnabled = YES;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  [_character.physicsBody.chipmunkObjects[0] eachArbiter:^(cpArbiter *arbiter) {
    if (!_jumped) {
      [_character.physicsBody applyImpulse:ccp(0, 2000)];
      _jumped = TRUE;
      [self performSelector:@selector(resetJump) withObject:nil afterDelay:0.3f];
    }
  }];
}

- (void)resetJump {
  _jumped = FALSE;
}

- (void)fixedUpdate:(CCTime)delta
{
  _character.physicsBody.velocity = ccp(40.f, _character.physicsBody.velocity.y);
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero flag:(CCNode *)flag {
  self.paused = YES;
  
  WinPopup *popup = (WinPopup *)[CCBReader load:@"WinPopup"];
  popup.positionType = CCPositionTypeNormalized;
  popup.position = ccp(0.5, 0.5);
  popup.nextLevelName = @"Level2";
  [self addChild:popup];
  
  return TRUE;
}

- (void)update:(CCTime)delta {
  if (CGRectGetMaxY([_character boundingBox]) <  CGRectGetMinY(_physicsNode.boundingBox)) {
    [self gameOver];
  }
}

- (void)gameOver {
  CCScene *restartScene = [CCBReader loadAsScene:@"Level1"];
  CCTransition *transition = [CCTransition transitionFadeWithDuration:0.8f];
  [[CCDirector sharedDirector] presentScene:restartScene withTransition:transition];
}

@end
